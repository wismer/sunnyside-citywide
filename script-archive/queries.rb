
require 'csv'
require 'sequel'
require 'prawn'
module Parser
  DB = Sequel.connect('sqlite://citywide-db.db')
  def self.find_invoice(file)
    val = 0.0
    tot = 0.0
    dif = 0.0
    PDF::Reader.new(file).pages.each do |page|
      # puts page.raw_content
      page.raw_content.split(/\n/).reject{|x| !x.include?('TOT INV#')}.each do |line|
        invoice_number, total = line.match(/^\(TOT INV#(\d{6})\s+([0-9,\.]+)/).captures
        val += DB[:invoices].where(:invoice_number => invoice_number.to_i).get(:invoice_amount)
        tot += total.gsub(/,/, '').to_f
        # print "#{invoice_number}, #{total}\n "
        if DB[:invoices].where(:invoice_number => invoice_number.to_i).get(:invoice_amount) != total.gsub(/,/, '').to_f.round(2)
          print "#{DB[:invoices].where(:invoice_number => invoice_number.to_i).all}, #{invoice_number}, #{total}\n"
        end
      end
    end
    puts val.round(2)
    puts tot.round(2)
    puts dif.round(2)
  end
end

Parser.find_invoice('20130826_9075_S22_CSHJN245_112832_1217.PDF')