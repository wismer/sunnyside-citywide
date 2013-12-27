module Sunnyside

  # REG LOC is the only repeating element that would indicate that there's a new client being read. So instead of reading the pdf
  # report page by page, it would be best to compress the text from every page into a single string and then parse from there.

  def self.parse_pdf
    Dir["#{LOCAL_FILES}/837/*.PDF"].select { |file| Filelib.where(filename: file).count == 0 }.each do |file|
      puts "processing #{file}..."
      data = PDF::Reader.new(file).pages.map { |page| page.raw_content.gsub(/^\(\s|\)'$/, '') }.join
      data.split(/^\((?=REG\s+LOC)/).each { |entry| ParseInvoice.new(entry).process } 
      Filelib.insert(filename: file, purpose: '837')
    end
  end

  class ParseInvoice
    attr_reader :client_line, :visits

    def initialize(entry)
      @client_line = entry.split(/\n/).select { |line| line =~ /\s+001\s+/ }
      @visits      = entry.split(/\n/).select { |line| line =~ /^\d{6}/         }
    end

    def invoice_lines
      visits.map { |inv| 
          InvoiceDetail.new(
            client_data, 
            { :invoice  => inv[0..5], 
              :svc_code => inv[18..22], 
              :modifier => inv[25..30], 
              :dos      => inv[57..66], 
              :units    => inv[69..75], 
              :amount   => inv[79..88] }
          )
      }
    end


    def client_data
      client_line.map { |line| ( line.slice(9..28) + line.slice(66..120) ).split }[0]
    end

    def process
      invoice_lines.each { |inv| inv.to_db }
    end

    # only the invoices lines and the client info line gets selected and passed onto the next object level
  end


  class InvoiceDetail < ParseInvoice
    attr_reader :invoice, :service_code, :modifier, :dos, :units, :amount, :client

    def initialize(client, invoice_line = {})
      @client       = ClientData.new(client)
      @invoice      = invoice_line[:invoice]
      @service_code = invoice_line[:svc_code]
      @modifier     = invoice_line[:modifier]
      @dos          = invoice_line[:dos]
      @units        = invoice_line[:units]
      @amount       = invoice_line[:amount]
    end

    def to_db
      Visit.insert(
        :client_id    => client.client_number, 
        :modifier     => modifier, 
        :invoice_id   => invoice,
        :amount       => amount,
        :service_code => service_code,
        :dos          => Date.strptime(dos, '%m/%d/%y'),
        :units        => units
      )
      update_invoice
    end

    def update_invoice
      Invoice[invoice].update(:auth => client.auth, :recipient_id => client.recipient_id)
    end
  end

  class ClientData < ParseInvoice
    attr_reader :client_id, :service_id, :recipient_id, :authorization

    def initialize(client)
      @client_id, @service_id, @recipient_id, @authorization = client.map { |line| line.strip }
    end

    def client_number
      if client_missing?
        puts 'how the hell is it happening? ' + client_id
      else
        client_id
      end
    end

    def auth
      authorization
    end

    def client_missing?
      Client[client_id].nil?
    end
  end
end