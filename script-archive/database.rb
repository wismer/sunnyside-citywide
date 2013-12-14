# USE THIS FILE TO PROCESS PAYMENTS FOR FUND EZ IMPORT

require 'prawn'
require 'sequel'
require 'csv'
module Parser
  include Enumerable

  def self.display_files
    file_dir = Dir.entries('./check-eco').entries.reject{|x| !x.include?('PDF')}
    file_dir.each_with_index do |file, index|
      print "#{index}.) #{file}\n"
    end
    print "Please choose which file to process... "
    answer = gets.chomp
    yield file_dir[answer.to_i]
  end

  def self.enter_check(check, post_date)
    invoices = Invoice.where(check: check).map(:invoice_number)
    
  end
  def self.add_invoice(inv)
    Invoice.where(:invoice_number => inv.to_i).all.each {|x| yield x}
  end

  def self.check_provider(prov)
    Provider.all.each {|provider| return provider if provider.name == prov}
  end

  def self.import_payment_by_check(check_number)
    Invoice.where(check: check_number.to_i).all.each {|x| yield x}
  end

  def self.to_csv(invoice, prov, receipt_num, post_date)
    CSV.open("./ledger-files/EDI-MISC-citywide-import.csv", "a+") do |row| # #{post_date.gsub(/\//, '-')}-
      row << [1, receipt_num, post_date, invoice.fund_id, invoice.invoice_number, invoice.invoice_number, "#{post_date[0..1]}/13#{prov.abbreviation}", post_date, invoice.invoice_number, prov.fund, prov.account,'','','', 0,  invoice.invoice_amount]
      row << [2, receipt_num, post_date, invoice.fund_id, invoice.invoice_number, invoice.invoice_number, "#{post_date[0..1]}/13#{prov.abbreviation}", post_date, invoice.invoice_number,       100,         1000,'','','', invoice.invoice_amount,    0]
      row << [3, receipt_num, post_date, invoice.fund_id, invoice.invoice_number, invoice.invoice_number, "#{post_date[0..1]}/13#{prov.abbreviation}", post_date, invoice.invoice_number, prov.fund,         3990, '', '', '', invoice.invoice_amount, 0]
      row << [4, receipt_num, post_date, invoice.fund_id, invoice.invoice_number, invoice.invoice_number, "#{post_date[0..1]}/13#{prov.abbreviation}", post_date, invoice.invoice_number,       100,         3990, '', '', '', 0, invoice.invoice_amount]
    end
  end
  class Invoice < Sequel::Model; end
  class Provider < Sequel::Model; end
end

# Parser.import_payment_by_check(ARGV[0]) do |inv|
#   data = Parser.check_provider(inv.provider)
#   Parser.to_csv(inv, data, inv.check, '08/26/2013')
# end

# CSV.open("import.csv", "a+") {|row| row << ['Seq', 'Receipt #', 'post_date', 'other id', 'invoice #', 'header memo', 'batch', 'doc date', 'detail memo', 'fund', 'account', 'cc1', 'cc2', 'cc3', 'debit', 'credit']}
# total = 0.0
# print 'post date? '
# post_date = gets.chomp
# print "type? "
# type = gets.chomp
# loop do
#   if type.upcase == 'P'    
#     print "check number? "
#     receipt_num = gets.chomp
#     print "add invoice: "
#     invoice = gets.chomp.split(' ')
#     invoice.each do |inv|
#       Parser.add_invoice(inv) do |line| 
#         print "#{line.client_name}: #{line.invoice_number} - #{line.invoice_amount} #{line.provider} -> SUBTOTAL: #{total+=line.invoice_amount}\n"
#         data = Parser.check_provider(line.provider)
#         Parser.to_csv(line, data, receipt_num, post_date)
#       end
#     end
#     break if invoice.empty?
#   elsif type.empty?
#     print "add invoice: "
#     invoice = gets.chomp
#     Parser.add_invoice(invoice) do |line| 
#       print "#{line.client_name}: #{line.invoice_number} - #{line.invoice_amount} #{line.provider} -> SUBTOTAL: #{total+=line.invoice_amount}\n"
#       data = Parser.check_provider(line.provider)
#       Parser.to_csv(line, data, receipt_num, post_date)
#     end
#     break if invoice.empty?
#   elsif type.upcase == 'MCO'
#     Parser.display_files do |file|
#       break if file.empty?
#       receipt_num = file.match(/(\d+)\.PDF$/).captures
#       Parser.parse_file(file, receipt_num.join, post_date) 
#     end
#   else
#     break
#   end
# end


alt_guildnet_list = ['AMRUNISSA, ALI', 'BUSTAMANTE, GAB', 'CEPEDA, TOMASA', 'LANZILOTTA, ROS', 'LUGO, DOLORES', 'MATEO, RAFAEL', 'ORTIZ, ANTHONY', 'PEREZ, MARIA', 'PROANO, ALICIA', 'RODRIGUEZ, JUAN', 'SANTIAGO, IVETH', 'SANTIAGO, VICTO', 'SWABY, CLARENCE', 'TOUSSAINT, MIGU', 'VEGA, ADELAIDA', 'WARD, ALTHEA']