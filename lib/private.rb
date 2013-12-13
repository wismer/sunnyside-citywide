module Sunnyside
  def self.process_private
    Dir["private/*.pdf"].each do |file|
      PDF::Reader.new(file).pages.each { |page| PrivateInvoice.new(page.text).process }
    end
  end

  class PrivateInvoice
    attr_reader :text, :services, :invoice_total
    def initialize(text)
      @text          = text
      @invoice_total = []
    end

    def process
      service_lines.map { |line| line[23..120] }.each { |line| strip_line(line) } if invoice
    end

    def strip_line(line)
      services = line.split(/\s+/)
      dos, amt = services[1], services.last
      invoice_total << amt.to_f
    end

    def invoice_match?
      Invoice.where(invoice_number: invoice.to_i).get(:amount) == find_total.round(2)
    end

    def find_total
      invoice_total.inject { |x, y| x + y }
    end

    def service_lines
      text.split(/\n/).select { |line| line =~ /HHA|PCA/ }
    end

    def invoice
      text[/^\s+\d+\s+[0-9\/]+\s+(\d+)/, 1]
    end
  end
end