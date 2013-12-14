require 'fileutils'
module Sunnyside

  # REG LOC is the only repeating element that would indicate that there's a new client being read. So instead of reading the pdf
  # report page by page, it would be best to compress the text from every page into a single string and then parse from there.

  def self.parse_pdf
    Dir["837-reports/*.PDF"].select { |file| Filelib.where(filename: file).count == 0 }.each do |file|
      puts "processing #{file}..."
      data = PDF::Reader.new(file).pages.map { |page| page.raw_content.gsub(/^\(\s|\)'$/, '') }.join
      data.split(/^\((?=REG\s+LOC)/).each { |entry| ParseInvoice.new(entry).process } 
      FileUtils.mv(file, "837-reports/archive/#{File.basename(file)}")
      Filelib.insert(filename: file)
    end
  end

  class ParseInvoice
    attr_reader :client_line, :visits

    def initialize(entry)
      @client_line = entry.split(/\n/).select { |line| line =~ /(NY|\s+)\s+001/ }
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

    # client_data should always have only a single element present (of an array).

    def client_data
      client_line.map { |line| ( line.slice(9..28) + line.slice(66..120) ).split }[0]
    end

    def process
      puts client_line
      puts visits
      invoice_lines.each { |inv| inv.to_db }
    end

    # only the invoices lines and the client info line gets selected and passed onto the next object level
  end
  class ClientData < ParseInvoice
    attr_reader :client_id, :service_id, :recipient_id, :authorization

    def initialize(client)
      @client_id, @service_id, @recipient_id, @authorization = client.map { |line| line.strip }
    end

    def show_me
      puts "#{client_id} #{service_id} #{recipient_id} #{authorization}"
    end

    def client_number
      if client_exists?
        client_id
      else
        insert_client
      end
    end

    def client_exists?
      Client.where(client_number: client_id).count > 0
    end

    def insert_client
      Client.insert(client_number: client_id)
    end
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

    def show
      puts "#{invoice} #{service_code} #{modifier} #{dos} #{units} #{amount} #{client.show_me}"
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
      Invoice[invoice].update(:auth => client.authorization, :recipient_id => client.recipient_id)
    end
  end
end