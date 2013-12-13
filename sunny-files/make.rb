require 'prawn'
require 'sequel'

module Sunnyside
  DB = Sequel.connect('sqlite://../project.db')
  
  def self.parse_pdf
    file = Dir["../private/*.PDF"][0]
    PDF::Reader.new(file).pages.each { |inv| InvoiceParse.new(inv.text.split(/\n/)).process if inv.text.include?('Remit') }
  end

  class InvoiceParse
    attr_reader :invoice_line, :client_line, :service_lines
    def initialize(page)
      @invoice_line  = page.select { |line| line =~ /[0-9\/]{8}\s+\d{7}/  }.join
      @client_line   = page.select { |line| line =~ /[0-9]{7}\s+[0-9]{7}/ }.join
      @service_lines = page.map { |line| ServiceLine.new(line) if line =~ /\sHHA\s|\sPCA\s/ }.compact
    end

    def invoice
      invoice_line[/(\d{7})$/, 1].gsub(/^0/, '')
    end

    def client_number
      client_line[/[0-9]{7}/, 0]
    end

    def process
      service_lines.each { |line| line.to_db(invoice, client_number) }
    end
  end
  class ServiceLine
    attr_reader :line

    def initialize(line)
      @line = line
    end

    def to_db(invoice, client_number)
      Visit.insert(invoice_number: invoice, member_id: client_number, dos: Date.strptime(service_date, '%m/%d/%y'), service_code: code, amount: amount)
    end

    def service_date
      line[/[0-9\/]{8}/, 0]
    end

    def code
      if line =~ / HHA /
        'HHA'
      else
        'PCA'
      end
    end

    def line_split
      line.split 
    end

    def amount
      line_split[-1]
    end

    def rate
      line_split[-2]
    end
  end
  class Visit < Sequel::Model; end
end

Sunnyside.parse_pdf