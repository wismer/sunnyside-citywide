module Sunnyside
  def self.edi_parser
    print "checking for new files...\n"
    Dir["#{DRIVE}/sunnyside-files/835/*.txt"].each do |file|
      print "processing #{file}...\n"
      data = File.open(file).read

      # Detect to see if the EDI file already has new lines inserted. If so, the newlines are removed before the file gets processed.

      data.gsub!(/\n/, '')

      data     = data.split(/~CLP\*/)

      edi_file = EdiReader.new(data)
      edi_file.parse_claims
      Filelib.insert(filename: file, purpose: '835')
      FileUtils.mv(file, "#{DRIVE}/sunnyside-files/835/archive/#{File.basename(file)}")
    end
  end

  class EdiReader 
    attr_reader :data

    def initialize(data)
      @data = data
    end

    def claims
      data.select { |clm| clm =~ /^\d+/ }.map { |clm| clm.split(/~(?=SVC)/) }
    end



    def check_number
      check = data[0][/(?<=~TRN\*\d\*)\w+/]
      return check.include?('E') ? check[/\d+$/] : check
    end

    def check_total
      data[0][/(?<=~BPR\*\w\*)[0-9\.\-]+/, 0]
    end

    def parse_claims
      payment_id = Payment.insert(check_number: check_number, check_total: check_total)
      claims.each { |claim| ClaimParser.new(claim, payment_id).parse }
    end
  end

  class ClaimParser < EdiReader
    attr_reader :claim_header, :service_data, :payment_id

    def initialize(claim, payment_id)
      @claim_header = claim[0].split(/\*/)
      @service_data = claim.select { |clm| clm =~ /^SVC/ }
      @payment_id   = Payment[payment_id]
    end

    def header
      {
        :invoice       => claim_header[0],
        :response_code => claim_header[1],
        :billed        => claim_header[2],
        :paid          => claim_header[3],
        :units         => claim_header[5], # 4 is not used - that is the patient responsibility amount
        :claim_number  => claim_header[6][/^\d+/]
      }
    end

    def parse
      claim    = ClaimEntry.new(header)
      claim_id = claim.to_db(payment_id) 
      service_data.each { |service| ServiceParser.new(service, claim_id).parse }
    end
  end

  class ClaimEntry < EdiReader
    attr_reader :invoice, :response_code, :billed, :paid, :units, :claim_number

    def initialize(header = {})
      @invoice       = header[:invoice].gsub(/[OLD]/, 'O' => '0', 'D' => '8', 'L' => '1').gsub(/^0/, '')[0..5].to_i # for the corrupt SHP EDI files
      @response_code = header[:response_code]
      @billed        = header[:billed]
      @paid          = header[:paid]
      @units         = header[:units]
      @claim_number  = header[:claim_number]
    end

    def to_db(payment)
      payment.update(provider_id: inv.provider_id) if payment.provider_id.nil?
      Claim.insert(
        :invoice_id     => invoice, 
        :payment_id     => payment.id, 
        :client_id      => inv.client_id, 
        :control_number => claim_number, 
        :paid           => paid, 
        :billed         => billed, 
        :status         => response_code, 
        :provider_id    => inv.provider_id,
        :recipient_id   => inv.recipient_id
      )
    end

    def inv
      Invoice[invoice]
    end
  end

  class ServiceParser < EdiReader
    attr_reader :service_line, :claim

    def initialize(service_line, claim_id)
      @service_line = service_line.split(/~/)
      @claim        = Claim[claim_id]
    end

    def dos
      service_line.detect { |svc| svc =~ /^DTM/ }[/\w+$/]
    end

    def service_header
      line = service_line[0].split(/\*/).drop(1)
      if line.length == 7 || line[1] != line[2]
        return line.uniq
      else
        return line
      end
    end

    def error_codes
      service_line.find_all { |section| section =~ /^CAS|^SE/ }.map { |code| code[/\w+\*\w+\*(\d+)/, 1] }
    end

    def parse
      service = ServiceEntry.new(service_header, dos, error_codes)
      service.to_db(claim)
    end
  end

  class ServiceEntry < EdiReader
    attr_reader :paid, :billed, :service_code, :units, :res_code, :error_codes, :dos

    def initialize(service_header, dos, error_codes)
      @service_code, @billed, @paid, @res_code, @units = service_header
      @dos         = Date.parse(dos)
      @error_codes = error_codes.map { |id| Denial[id].denial_explanation }
    end

    def to_db(claim)
      Service.insert(
        :claim_id      => claim.id, 
        :invoice_id    => claim.invoice_id, 
        :payment_id    => claim.payment_id, 
        :denial_reason => denial_reason, 
        :service_code  => service_code.gsub(/HC:/, ''),
        :paid          => paid,
        :billed        => billed,
        :units         => units,
        :dos           => dos
      )
    end

    def denial_reason
      error_codes.join("\n") if denied?
    end

    def denied?
      paid != billed
    end
  end
end