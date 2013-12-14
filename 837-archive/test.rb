require 'prawn'
require 'sequel'
require 'date'
DB = Sequel.connect('sqlite://../project.db')

module Sunnyside
  def self.parse_pdf(file)
    puts "processing #{file}..."
    data = ''
    PDF::Reader.new(file).pages.each { |page| 
      data << page.raw_content 
    }
    split_data = InvoiceEntry.new(data)
    # split_data.extract_invoice(file)
    split_data.extract_client
  end
  class InvoiceEntry
    attr_reader :data
    def initialize(data)
      @data = data
    end

    def extract_client
      data.split(/\n/).reject{|line| line !~ /^\(NY\s+\d+/}.each {|line| 
        line.scan(/\S+\s+\S+\s+(\S+)\s+(\S+)\s+(.{24})\S+\s+(\S+)\s+(\S+)/) do |ln|
          puts line
        end
        # ClientEntry.new(line)
      }
    end

    def extract_invoice(file)
      data.split(/\n/).select {|line| line =~ /^\(\s\d{6}\s+/}.each do |line|
        line.scan(/\S+\s+(\S+)\s+\S+\s+(\S+)\s+(\S{2})?\s+\d{4}?\s+(\S+)\s+\S+\s+(\S+)\s+(\S+)/) do |ln|
          # print "#{ln}\n"
          line = LineEntry.new(ln)
          line.map_to_db(file)
        end
      end
    end
  end

  class LineEntry
    attr_reader :invoice, :service_code, :dos, :modifier, :amount, :units
    def initialize(line)
      @invoice, @service_code, @modifier, @dos, @units, @amount = line
    end

    def map_to_db(file)
      if modifier
        @service_code = service_code + ':' + modifier
      end
      if Invoice[invoice]
        Charge.insert(invoice_id: invoice, service_code: service_code, dos: Date.strptime(dos, '%m/%d/%y'), units: units, amount: amount, filename: file, provider_id: prov_id)
      end
    end

    def prov_id
      Invoice[invoice].provider_id
    end
  end

  class ClientEntry
    def initialize(line)
      @client_number, @service_number, @client, @recipient_id, @authorization = line.match(/\S+\s+\S+\s+(\S+)\s+(\S+)\s+(.{24})\S+\s+(\S+)\s+(\S+)/).captures
    end

    def show_data
      puts "#{@client_number} #{@service_number} #{@client} #{@recipient_id} #{@authorization}"
      add_client
    end

    def add_client
      # Client.where(recipient_id: nil, med_id: @client_number).update(recipient_id: @recipient_id)
    end
  end

  class Charge < Sequel::Model; end
  class Client < Sequel::Model; end
  class Invoice < Sequel::Model; end
end

Dir["../837-reports/*.PDF"].each do |file| 
  Sunnyside.parse_pdf(file)
end














      # split_data.find_client
      # split_data.find_service
      # # provider = client[/^\(PAYER\s+ID.+/]
      # # lines = []
      # client.split(/\n/).each {|line|
      #   if line =~ /^\(NY\s+\d+/
      #     client_entry = ClientEntry.new(line)
      #   elsif line =~ /^\(\s+\d{6}/
      #     # puts line
      #     line.scan(/\S+\s+(\S+)\s+\S+\s+(\S+)\s+(\S{2})?\s+\d{4}?\s+(\S+)\s+\S+\s+(\S+)\s+(\S+)/) do |ln|
      #       line_entry = LineEntry.new(ln)
      #       lines << line_entry
      #     end
      #   end