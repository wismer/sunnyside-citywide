module Sunnyside
  DB = Sequel.connect("sqlite://sunnyside.db")

  class Base
    def pages
      until @files.empty? do
        reader = PDF::Reader.new(@files.shift)

        reader.pages.map.with_index do |page, index|
          yield page.raw_content, index if !page.raw_content.include?("VISITING NURSE SERVICE")
        end
      end
    end

    def to_lines
      pages.map { |page| page.split("\n") }.flatten
    end

    def filter_line(line)
      entry = line.gsub(@options[:pattern], @options[:params])
      name = entry.slice!(@options[:name]) if @options[:name]

      entry = @attributes.zip(entry.split).to_h
      entry[:name] = name.strip if @options[:name]

      return entry
    end

    def invoice_exists?
      !Invoice[@invoice].nil?
    end

    def client_exists?
      !Client[@client_id].nil?
    end

    def insert_client
      Client.insert(provider_id: provider_id, client_id: @client_id)
    end

    def provider_id
      Provider.where(name: @provider)
    end
  end

  class Ledger < Base
    attr_reader :attributes
    def initialize
      @files = SunnyFiles.ledger
      @page_data = {}
      @options = {
        pattern: /[\(\)\']|\x00/,
        params: { "\x00" => "-", "\)'" => "", "\(" => "" },
        name: 20..45
      }

      @attributes = [:post_date, :invoice, :client_id, :hours, :rate, :amount]
    end

    def read
      pages do |page, index|
        invoice_lines = page.split(/\n/).select { |line| line =~ /^\([0-9\/]{8}\s/ }
        invoice_lines.map! { |line| filter_line(line) }

        @page_data[index] = {
          provider:      page[/CUSTOMER:\s+(.+)(?=\)')/, 1],
          invoice_lines: invoice_lines
        }
      end

      @page_data.each do |k,data|
        data[:invoice_lines].each do |line|
          invoice = InvoiceLine.new(data[:provider], line)
          invoice.save_to_db
        end
      end
    end
  end

  class InvoiceLine < Base
    def initialize(provider, line={})
      @post_date = line[:post_date]
      @invoice   = line[:invoice]
      @client_id = line[:client_id]
      @hours     = line[:hours]
      @rate      = line[:rate]
      @amount    = line[:amount]
      @provider  = provider
    end

    def save_to_db
      insert_client if !client_exists?
      update_invoice if invoice_exists?

      Invoice.insert(
        invoice_number: @invoice,
        client_id: @client_id,
        hours: @hours,
        rate: @rate,
        amount: parse_amount,
        provider_id: provider_id,
        post_date: parse_data
      )
    end
  end


  class SunnyFiles
    def self.ledger
      Dir["./*.pdf"]
    end
  end
end




# sunnyside status
# checks for all new files and prints them out

# sunnyside import <type> <optional>


# sunnyside import ledger -all
# sunnyside import cash -all
# sunnyside import ledger some_file.pdf
