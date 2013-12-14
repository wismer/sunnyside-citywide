require 'prawn'
require 'sequel'
require 'csv'

module Cycle
  DB = Sequel.connect('sqlite://citywide-db.db')

  def self.import_to_db()
    
  end


  def self.check_for_private(line)
    if !DB[:providers].map(:name).include?(line[2])  
      line[2] = 'PRIVATE'
      Cycle.check_provider(line)
    else
      line[2] = 'AMERIGROUP' if line[2] == 'AMERIGROUP 2'
      Cycle.check_provider(line)
    end
  end

  def self.check_provider(line) # if provider is in the database, data moves forward. need to add an exception for Private and Amerigroup 2 clients
    DB[:providers].each {|prov| Cycle.check_client(line) if line[2] == prov[:name]}
  end

  def self.check_client(line) # retrieves the fund ez id
    DB[:clients].each {|client| Cycle.add_to_db(line, client[:fund_id]) if client[:name] == line[3]}
  end

  def self.orphaned_client(line)
    CSV.open('missing_client.csv', 'a+') {|row| row << line}
  end

  def self.add_to_db(line, client_id) # adds to invoice db
    DB[:invoices].insert(:client_name => line[3], :invoice_number => line[0].to_i, :fund_id => client_id, :invoice_amount => line[4].gsub(/,/, '').to_f, :provider => line[2])
  end

  def self.check_details(line)
    invoice = DB[:invoices].where(:invoice_number => line[0].to_i)
    Cycle.add_detail(line, invoice) if invoice
  end

  def self.add_detail(line, invoice)
    DB[:details].insert(
      :invoice_number => line[0].to_i, 
      :service_code   => line[1], 
      :modifier       => line[2],
      :provider       => invoice.get(:provider),
      :client_name    => invoice.get(:client_name),
      :service_date   => Date.strptime(line[3], '%m/%d/%y'),
      :units          => line[4].to_f,
      :amount         => line[5].to_f,
      :invoice_id     => invoice.get(:id)
    )
  end

  def self.update_post_date(line, post_date)
    DB[:invoices].where(:invoice_number => line[0].to_i).update(:post_date => post_date.strftime("%m/%d/%Y"))
  end

  def self.create_csv(post_date, method)
    Invoice.where(:post_date => post_date).all.each do |inv|
      prov = Provider.where(:name => inv.provider).first
      Ledger.new.cash_receipts(inv, prov) if method == 'import'
      Cycle.create_import(inv, prov, post_date) if method == 'export'
    end
  end

  def self.display_totals_by_provider(post_date)
    Provider.map(:name).each do |prov|
      CSV.open("summary_citywide.csv", "a+") {|row| row << [prov, Invoice.where(:provider => prov, :post_date => post_date).sum(:invoice_amount).to_s, post_date]
    end
  end

  def self.create_import(inv, prov, post_date)
    if post_date
      CSV.open("ar_inv_import.csv", "w+") do |row|
        row << ['Seq', 'invoice', 'post_date', 'client', 'id', 'provider', 'doc date', 'header memo', 'batch', 'due date', 'detail memo', 'fund', 'acct', 'cc1', 'cc2', 'cc3', 'debit', 'credit']
        invoices.each do |invoice|
          row << [1, , @post_date, @client, @client_id, @provider, @post_date, "To Record #{ARGV[1]} Billing", "#{ARGV[2]}#{@detail[:abbrev]}", @post_date, "To Rec for W/E #{ARGV[3]} Billing", @detail[:fund],       @detail[:account],            '', '', @amount,     '']
          row << [2, , @post_date, @client, @client_id, @provider, @post_date, "To Record #{ARGV[1]} Billing", "#{ARGV[2]}#{@detail[:abbrev]}", @post_date, "To Rec for W/E #{ARGV[3]} Billing", @detail[:fund], @detail[:debit_account], @detail[:cc1], '',      '',@amount]
      end
    end
  end

  class Ledger
    def ar_create_csv
      
    end

    def cash_receipts(invoice, prov)
      CSV.open("ar_import.csv", "a+") do |row|
        row << [1, "#{ARGV[1]}", invoice.post_date, invoice.fund_id, invoice.invoice_number, invoice.invoice_number, "08/13#{prov.abbreviation}", invoice.post_date, invoice.invoice_number, prov.fund, prov.account,'','','', 0,  invoice.invoice_amount]
        row << [2, "#{ARGV[1]}", invoice.post_date, invoice.fund_id, invoice.invoice_number, invoice.invoice_number, "08/13#{prov.abbreviation}", invoice.post_date, invoice.invoice_number,       100,         1000,'','','', invoice.invoice_amount,    0]
        row << [3, "#{ARGV[1]}", invoice.post_date, invoice.fund_id, invoice.invoice_number, invoice.invoice_number, "08/13#{prov.abbreviation}", invoice.post_date, invoice.invoice_number, prov.fund,         3990, '', '', '', invoice.invoice_amount, 0]
        row << [4, "#{ARGV[1]}", invoice.post_date, invoice.fund_id, invoice.invoice_number, invoice.invoice_number, "08/13#{prov.abbreviation}", invoice.post_date, invoice.invoice_number,       100,         3990, '', '', '', 0, invoice.invoice_amount]
      end
    end
  end
  class Provider < Sequel::Model; end
  class Invoice < Sequel::Model; end
  class Client < Sequel::Model; end
end
# Dir.entries(Dir.pwd).each do |file|
#   if file =~ /9075/
#     print "processing #{file}...\n"
#     PDF::Reader.new(file).pages.each do |page|
#       page.raw_content.scan(/(\d{6})\s+(\d+\/\d+\/\d+)\s+\d+\s+(.{3,30})\s+(.{3,15})\s+\d+\.\d+\s+(\d,?\d+\.\d+)/) do |line|
#         line.collect {|x| x.strip!}
#         Cycle.check_provider(line)
#       end
#     end
#   end
# end
# Dir.entries(Dir.pwd).each do |file|
#   if file =~ /9075/
#     print "processing #{file}...\n"
#     PDF::Reader.new(file).pages.each do |page|
#       page.raw_content.scan(/(\d{6})\s+(\d+\/\d+\/\d+)\s+\d+\s+(.{3,30})\s+(.{3,15})\s+\d+\.\d+\s+(\d,?\d+\.\d+)/) do |line|
#         line.collect {|x| x.strip!}
#         Cycle.update_post_date(line, Date.parse(file[0..7]))
#       end
#     end
#   end
# end
# Cycle.display_totals_by_provider("07/31/2013")
Cycle.create_csv("#{ARGV[0]}", 'import') if !"#{ARGV[0]}".nil?

# Cycle.display_totals_by_provider(251973..252837)
# Dir.entries("#{Dir.pwd}"+"/detail").each do |file|
#   puts file
#   if file =~ /9075/
#     print "processing #{file}...\n"
#     # puts File.extname(file)
# Dir.entries("#{Dir.pwd}" + "/summary").each do |file|
#   if file =~ /9075/
#     print "processing #{file}\n"
#     PDF::Reader.new("#{Dir.pwd}/detail/#{file}").pages.each do |page|
#       page.raw_content.scan(/^\(\s(\d{6})\s+\d\s+(\w\d{4})\s+(0580|TT|1C|1C\s+1F)?\s+(\d+\/\d+\/\d+)\s+\d+\/\d+\/\d+\s+(\d+\.\d+)\s+(\d+\.\d+)/) do |line|        
#         line.collect {|x| x.strip! if !x.nil?}
#         print "#{line.join(' ')}\n"
#         Cycle.check_details(line)
#       end
#     end
#   end
# end
#   end
# end
# /^(\d{6})\s+\d\s+(\w\d{4})\s+(0580|TT|C1)?\s+(\d+\/\d+\/\d+)\s+\d+\/\d+\/\d+\s+(\d+\.\d+)\s+(\d+\.\d+)/
# /(\d{6})\s+(\d+\/\d+\/\d+)\s+\d+\s+(.{3,30})\s+(.{3,15})\s+\d+\.\d+\s+(\d,?\d+\.\d+)/