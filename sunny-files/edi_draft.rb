
module Sunnyside
  def self.edi_parser_draft
    puts "checking for new files..."
    Dir["835/*.txt"].each do |file|
      if file =~  /MSG264260376_CHK20131108101003190EPRA3757694_20131108.835.txt/
        data  = File.open(file).read.split(/~(?=CLP\*)/)
        puts "Processing #{file}..."
        EdiDraft.new(data).edi_header
      end
      # Filelib.insert(filename: file, created_at: Time.now, purpose: 'EDI Import', file_type: '835 Remittance')
    end
  end
  class EdiDraft
    attr_reader :header, :claims, :check_number, :check_amount
    def initialize(data)
      @header, @claims = data[0], data.drop(1)
    end

    def edi_header
      if header[/(?<=\*C\*)ACH/] == 'ACH'
        @check_number = header[/(?<=~TRN\*\w\*)\w+/]
        @check_amount = header[/(?<=~BPR\*\w\*)[0-9\.\-]+/]
      elsif header[/(?<=\*C\*)CHK/] == 'CHK'
        @check_number = header[/(?<=~TRN\*\d\*)\d+/]
        @check_amount = header[/(?<=~BPR\*\w\*)[0-9\.\-]+/]
      else
        @check_number = 0
        @check_amount = 0.0
      end
      find_claims
    end

    def seperate_sections_of_claim
      claims.map { |clm| clm.split(/~(?=SVC)/) }
    end

    def find_claims
      seperate_sections_of_claim.each { |clm| ClaimParser.new(check_number, check_amount, clm).process }
    end

    def to_hash(claim)
      {
        :header => claim[0],
        :body   => claim.drop(1)
      }
    end
  end

  class ClaimParser
    attr_reader :claim_header, :claim_body, :check_number, :check_amount
    def initialize(check_number, check_amount, claim)
      @check_number = check_number
      @check_amount = check_amount
      @claim_header = claim[0]
      @claim_body   = claim.select { |svc| svc =~ /^SVC/ } 
    end

    def process
      services.each { |svc| svc.process }
    end

    def method_name
      
    end

    def header
      ClaimHeader.new(claim_header)
    end

    def services
      claim_body.map { |svc| ClaimServices.new(svc) }
    end

    def to_s
      # "#{claim}"
    end
  end

  class ClaimServices < ClaimParser
    def initialize(service, date=nil, cas=nil, ref=nil, amt=nil)
      @service = service
    end
  end

  class ClaimHeader
    attr_reader :claim_header

    def initialize(claim_header)
      @claim_header = claim_header.split(/~/).reject {|x| x=~/^DTM/}
    end

    def sort_header
      claim_header.map{|section|
        if section =~ /^NM1\*QC/
          section = section.gsub(/^NM1\*QC\*\d\*/, '')
          create_client_data(section)
        else
          # InvoiceData.new(section)
        end 
      }
      # puts "#{claim_header}"
    end


    def create_client_data(section)
      first_name, last_name = section
    end
  end

  class ClaimBody < ClaimHeader
    def initialize(claim_body)
      @claim_body = claim_body
    end
  end

  class ClientData < EdiDraft
    def initialize(line)
      @first, @last, @initial, @recipient_id = line
    end

    def method_name
      
    end
  end
end

