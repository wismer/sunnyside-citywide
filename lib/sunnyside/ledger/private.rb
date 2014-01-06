module Sunnyside  
  def self.process_private
    Dir["#{DRIVE}/sunnyside-files/private/*.PDF", "#{DRIVE}/sunnyside-files/private/*.pdf"].select { |file| Filelib.where(filename: file).count == 0 }.each do |file|
      puts "processing #{file}..."
      PDF::Reader.new(file).pages.each { |inv| 
        page  = inv.text.split(/\n/)
        InvoiceParse.new(page).process if page.include?('Remit') 
      }
      Filelib.insert(filename: file, purpose: 'private client visit data')
      FileUtils.mv(file, "#{DRIVE}/sunnyside-files/private/archive/#{File.basename(file)}")
    end
  end

  class InvoiceParse
    attr_reader :invoice_line, :client_line, :service_lines
    def initialize(page)
      @invoice_line  = page.select { |line| line =~ /[0-9\/]{8}\s+\d{7}/  }.join
      @client_line   = page.select { |line| line =~ /[0-9]{7}\s+[0-9]{7}/ }.join
      @service_lines = page.map    { |line| ServiceLine.new(line) if line =~ /\sHHA\s|\sPCA\s/ }.compact
    end

    def invoice
      invoice_line[/(\d{7})$/, 1].gsub(/^0/, '')
    end

    def client_number
      client_line[/[0-9]{7}/]
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
      Visit.insert(invoice_id: invoice, client_id: client_number, dos: Date.strptime(service_date, '%m/%d/%y'), service_code: code, amount: amount)
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
end

