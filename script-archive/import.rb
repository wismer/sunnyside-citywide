# AS OF 8/21/2013, THIS SCRIPT:
#           1.) Imports CITYWIDE invoices from the Sales Register PDF file found in Archive website, with only a single argument (the file name of the pdf)
#           2.) Exports CITYWIDE invoices from the database (citywide-db.db) by POST DATE into a CSV FILE in this format: "<post-date>_citywide.csv" 
# IT DOES NOTHING ELSE OTHER THAN THE TWO LISTED
require 'prawn'
require 'sequel'
require 'csv'


module Cycle
  DB = Sequel.connect('sqlite://citywide-db.db')

  def self.import_to_db(file)
    PDF::Reader.new('./archive/citywide/'+file).pages.each do |page|
      page.raw_content.scan(/^\((\d{6})\s+([0-9\/]+)\s+\d+\s+(.{3,30})\s+(.{3,15})\s+([0-9\.,]+)\s+([0-9\.,]+)/) do |line|
        line.collect {|invoice| invoice.strip!} 
        invoice = Import.new(line, Date.parse(file[0..7])) unless line.include?("VISITING NURSE SERVICE")
        if invoice && !invoice.duplicate?
          print "#{line}\n"
          invoice.check_for_private
          invoice.check_client
        end
      end
    end
  end

  def self.create_csv(post_date)
    Invoice.where(post_date: post_date).all.each do |inv|
      Provider.all.each {|prov| Ledger.new(prov, inv, post_date) if prov.name == inv.provider}
    end
  end

  class Invoice < Sequel::Model; end
  class Provider < Sequel::Model; end
  class Client < Sequel::Model; end
  class Import
    attr_accessor :line, :post_date
    def initialize(line, post_date)
      @line      = line
      @post_date = post_date.strftime("%m/%d/%Y")
    end

    def duplicate?
      Invoice.where(invoice_number: @line[0].to_i).all.length > 0
    end

    def update_hours
      DB[:invoices].where(:invoice_number => @line[0].to_i).update(:hours => @line[4].to_f)
    end    

    def check_for_private
      if !DB[:providers].map(:name).include?(self.line[2])  
        @line[2] = 'PRIVATE'
      else
        @line[2] = 'AMERIGROUP' if @line[2] == 'AMERIGROUP 2'
      end
    end

    def check_client
      fund_id = DB[:clients].where(:name => @line[3]).get(:fund_id)
      if fund_id 
        add_to_db(fund_id) 
      else
        print "#{@line}\n"
        print "add client to fund EZ. Type in the ID now: "
        id = gets.chomp
        print "now type in the name AS IT APPEARS above: "
        name = gets.chomp
        Client.insert(name: name, fund_id: id)
        check_client
      end
    end

    def add_to_db(client_id)
      @line[4] = @line[4].to_f * 11 if client_id == '2002664' # luskind abberration
      puts DB[:invoices].insert(:client_name => @line[3], :invoice_number => @line[0].to_i, :fund_id => client_id, :invoice_amount => @line[5].gsub(/,/, '').to_f, :provider => @line[2], :post_date => @post_date, :hours => @line[4].to_f)
    end
  end

  class Ledger
    attr_accessor :invoice, :provider, :post_date

    def initialize(provider, invoice, post_date)
      @provider, @invoice, @post_date = provider, invoice, post_date
      into_csv
    end

    def into_csv
      CSV.open("./ledger-files/#{post_date.gsub(/\//, '-')}_citywide.csv", "a+") do |row|
        row << [1, @invoice.invoice_number, @post_date, @invoice.fund_id, @provider.name, @post_date, "To Record #{ARGV[0]} Billing", "#{@post_date[0..1]}/13#{@provider.abbreviation}", @post_date, "To Rec for W/E #{ARGV[1]} Billing", @provider.fund,       @provider.account,             '', '',                  '',@invoice.invoice_amount,                          '']
        row << [2, @invoice.invoice_number, @post_date, @invoice.fund_id, @provider.name, @post_date, "To Record #{ARGV[0]} Billing", "#{@post_date[0..1]}/13#{@provider.abbreviation}", @post_date, "To Rec for W/E #{ARGV[1]} Billing", @provider.fund, @provider.debit_account, @provider.fund, '',      @provider.type,                     '',     @invoice.invoice_amount]
      end
      DB[:invoices].where(invoice_number: @invoice.invoice_number).update(imported: 'true')
    end
  end
end

# Dir.entries('.').each do |file|
#   if file =~ /pdf|PDF/
#     print "processing: #{file}\n"
#     Cycle.import_to_db(file) 
#   end
# end
 # use this to import from PDF file into the database


# Cycle.import_to_db("#{ARGV[0]}")
# Cycle.create_csv("#{ARGV[0]}") # use this to export data into csv file for fund ez 

# files = Dir.entries('./archive/').reject{|x| !x.include?('.PDF')}
# files.each do |file|
#   print "processing #{file}...\n"
#   Cycle.import_to_db(file)
# end
# Cycle.monkey_patch