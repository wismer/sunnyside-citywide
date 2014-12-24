module Sunnyside
  class Ledger < Base
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
end