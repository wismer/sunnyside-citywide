require "sequel"
require "csv"
require "prawn"
# DB = Sequel.connect('sqlite://homecare.db')

# PROVIDER_LIST_PROJECT = {
#   "GUILDNET"                      => {abbrev:   'G', fund: 600, account: 1405, debit_account: 5405, cat: 'homecare'},
#   "HOMEFIRST/ELDERPLAN"           => {abbrev: 'HOM', fund: 600, account: 1430, debit_account: 5430, cat: 'homecare'},
#   "SENIOR WHOLE HEALTH"           => {abbrev: 'SWH', fund: 600, account: 1420, debit_account: 5420, cat: 'homecare'},
#   "SENIOR HEALTH PARTNERS"        => {abbrev: 'SHP', fund: 600, account: 1415, debit_account: 5415, cat: 'homecare'},
#   "INDEPENDENCE CARE SYSTEMS"     => {abbrev: 'ICS', fund: 600, account: 1410, debit_account: 5410, cat: 'homecare'},
#   "COMPREHENSIVE CARE MGMT CORP." => {abbrev: 'CCM', fund: 600, account: 1425, debit_account: 5425, cat: 'homecare'},
#   "EMBLEM HEALTH"                 => {abbrev: 'EMB', fund: 600, account: 1402, debit_account: 5402, cat: 'homecare'},
#   "ELDERSERVE"                    => {abbrev: 'ELD', fund: 600, account: 1404, debit_account: 5404, cat: 'homecare'},
#   "HHH CHOICES HEALTH PLAN"       => {abbrev: 'HHH', fund: 600, account: 1406, debit_account: 5406, cat: 'homecare'},
#   "VILLAGE CARE MAX"              => {abbrev: 'VCX', fund: 600, account: 1403, debit_account: 5403, cat: 'homecare'},
#   "AMERIGROUP"                    => {abbrev: 'AMG', fund: 600, account: 1401, debit_account: 5401, cat: 'homecare'},
#   "AGEWELL NY, C/O RELAY HEALTH"  => {abbrev: 'AGE', fund: 600, account: 1407, debit_account: 5407, cat: 'homecare'},
#   "AETNA BETTER HEALTH"           => {abbrev: 'AET', fund: 600, account: 1408, debit_account: 5408, cat: 'homecare'},
#   "ARCHCARE COMMUNITY LIFE"       => {abbrev: 'ARC', fund: 600, account: 1409, debit_account: 5409, cat: 'homecare'},
#   "VNS SELECT OF NEW YORK"        => {abbrev: 'VCP', fund: 600, account: 1400, debit_account: 5400, cat:      'vns'}
# }
# DB.create_table :invoices do
#   primary_key :id
#   String      :client_name
#   Integer     :invoice_number
#   Float       :invoice_amount
#   String      :provider
#   String      :fund_id
# end

# DB.create_table :clients do
#   primary_key :id
#   String      :name
#   String      :fund_id
# end

# DB.create_table :providers do
#   primary_key :id
#   String      :name
#   Integer     :fund
#   Integer     :account
#   Integer     :debit_account
#   String      :abbreviation
# end

# CSV.foreach("homecare_client_list.csv") do |row|
#   DB[:clients].insert(:name => row[0], :fund_id => row[1])
# end

# PROVIDER_LIST_PROJECT.each do |k, v|
#   DB[:providers].insert(:name => k, :fund => v[:fund], :account => v[:fund], :debit_account => v[:debit_account], :abbreviation => v[:abbrev])
# end

module Cycle
  DB = Sequel.connect('sqlite://homecare.db')
  def self.add_invoice(inv)
    Invoice.where(:invoice_number => inv.to_i).all.each {|x| yield x}
  end

  def self.check_provider(prov)
    Provider.all.each {|provider| return provider if provider.name == prov}
  end

  def self.check_provider_new(line) # if provider is in the database, data moves forward. need to add an exception for Private and Amerigroup 2 clients
    DB[:providers].each {|prov| Cycle.check_client(line) if line[2] == prov[:name]}
  end

  def self.check_client(line) # retrieves the fund ez id
    DB[:clients].each {|client| Cycle.add_to_db(line, client[:fund_id]) if line[3] == client[:name]}
  end

  def self.add_to_db(line, client_id) # adds to invoice db
    DB[:invoices].insert(:client_name => line[3], :invoice_number => line[0].to_i, :fund_id => client_id, :invoice_amount => line[4].gsub(/,/, '').to_f, :provider => line[2])
  end

  def self.to_csv(invoice, prov, receipt_num, post_date)
    CSV.open("import_homecare.csv", "a+") do |row|
      row << [1, receipt_num, post_date, invoice.fund_id, invoice.invoice_number, invoice.invoice_number, "07/13#{prov.abbreviation}", post_date, invoice.invoice_number, prov.fund, prov.account,'','','', 0,  invoice.invoice_amount]
      row << [2, receipt_num, post_date, invoice.fund_id, invoice.invoice_number, invoice.invoice_number, "07/13#{prov.abbreviation}", post_date, invoice.invoice_number,       600,         1000,'','','', invoice.invoice_amount,    0]
    end
  end

  class Invoice < Sequel::Model
    one_to_many :details
  end

  class Provider < Sequel::Model; end

  class Detail < Sequel::Model
    many_to_one :invoices
  end
end
# Dir.entries(Dir.pwd).each do |file|
#   if file =~ /9938/
#     print "processing #{file}...\n"
#     PDF::Reader.new(file).pages.each do |page|
#       page.raw_content.scan(/(\d{6})\s+(\d+\/\d+\/\d+)\s+\d+\s+(.{3,30})\s+(.{3,15})\s+\d+\.\d+\s+(\d,?\d+\.\d+)/) do |line|
#         line.collect {|x| x.strip!}
#         Cycle.check_provider(line)
#       end
#     end
#   end
# end
loop do
  print "add invoice\n"
  invoice = gets.chomp
  Cycle.add_invoice(invoice) do |line| 
    print "#{line.client_name}: #{line.invoice_number} - #{line.invoice_amount} #{line.provider}\n"
    data = Cycle.check_provider(line.provider)
    print "#{data.name}\n"
    Cycle.to_csv(line, data, '118788', '07/31/13')
  end
  break if invoice.empty?
end