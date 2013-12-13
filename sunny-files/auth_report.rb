module Sunnyside
  def self.parse_pdf
    Dir["837-reports/*.PDF"].each do |file|
      if !Filelib.map(:filename).include?(file)
        puts "processing #{file}..."
        data = ''
        PDF::Reader.new(file).pages.each { |page| 
          # puts page.raw_content
          data << page.raw_content
        }
        data.split(/^\((?=REG\s+LOC)/).each { |entry| ParseInvoice.new(entry).parse }
        Filelib.insert(filename: file, purpose: 'visit breakdown', file_type: '.pdf')
      end
    end
  end

  class ParseInvoice
    attr_reader :entry_data, :header, :detail

    def initialize(entry_data)
      @entry_data = entry_data.split(/\n/).select { |line| line =~ /^\(/ }
    end

    def header
      @header = entry_data[0]
    end

    def detail
      @detail = entry_data.select { |line| line =~ /^\(\s\d{6}\s+/ }
    end

    def parse
      if header && detail.size > 0
        client_num, svc_number, recip_id, auth = header[11..17], header[21..28], header[67..85], header[86..120]
        auth     = auth.gsub(/\)'|\s/, '') if auth
        recip_id = recip_id.strip if recip_id
        invoice                                = InvoiceData.new(client_num, svc_number, recip_id, auth, detail)
        invoice.extract_invoice
      end
    end
  end

  class InvoiceData
    attr_reader :client_num, :svc_number, :recip_id, :auth, :invoice, :detail
    def initialize(client_num, svc_number, recip_id, auth, detail)
      @client_num, @svc_number, @recip_id, @auth = client_num, svc_number, recip_id, auth
      @detail                                    = detail
      update_invoice
    end

    def invoice
      @invoice = detail[0][/^\(\s(\d{6})/, 0].gsub(/^\(\s+/, '')
    end

    def update_invoice
      Invoice.where(invoice_number: invoice).update(recipient_id: recip_id, auth: auth) if invoice
    end

    def extract_invoice
      detail.map! { |line| 
        line.gsub(/^\(\s+|\)'/, '').scan(/^(\S+)\s+\S+\s+(\S+)\s+(\S{2})?\s+(\S{2})?\s+(\d{3,4})?\s+(\S+)\s+\S+\s+(\S+)\s+(\S+)/) do |ln|
          LineDetail.new(ln).insert_to_db
          # puts line if Date.strptime(ln[5], '%m/%d/%y') > Date.today
        end
      }
    end
  end
  class LineDetail < InvoiceData
    attr_reader :invoice, :service_code, :modifier_1, :modifier_2, :modifier_3, :dos, :units, :amount

    def initialize(line) 
      @invoice, @service_code, @modifier_1, @modifier_2, @modifier_3, @dos, @units, @amount = line
    end

    def wrong_date?
      Date.strptime(dos, '%m/%d/%y') > Date.today
    end

    def date
      if wrong_date?
        Date.strptime(dos.gsub(/20$/, '11'), '%m/%d/%y') 
      else
        Date.strptime(dos, '%m/%d/%y')
      end
    end

    def modifiers
      [modifier_1, modifier_2, modifier_3]
    end

    def mod
      modifiers.join(':') if modifiers.any? { |m| !m.nil? }
    end

    def amt
      amount.gsub(/,/, '')
    end

    def insert_to_db
      if invoice_present?
        Visit.insert(invoice_number: invoice, service_code: service_code, modifier: mod, amount: amt, dos: date, units: units)
      else
        record_missing
      end
    end

    def invoice_present?
      Invoice.where(invoice_number: invoice).count > 0
    end

    def record_missing
      CSV.open('missing.csv', 'a+') { |row| row << [invoice, service_code, mod, amt, date] }
    end
  end
  class Visit < Sequel::Model; end
end