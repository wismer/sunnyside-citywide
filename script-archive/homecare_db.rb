#

require 'prawn'
require 'sequel'
require 'csv'

module Cycle
  DB = Sequel.connect('sqlite://homecare.db')

  def self.import_to_db(file)
    errors = []
    PDF::Reader.new('./homecare-files/'+file).pages.each do |page|
      page.raw_content.scan(/(\d{6})\s+(\d+\/\d+\/\d+)\s+\d+\s+(.{3,30})\s+(.{3,15})\s+(\d+\.\d+)\s+([0-9,\.]+)/) do |line|
        line.collect {|invoice| invoice.strip!} 
        invoice = Entry.new(line, Date.parse(file[0..7])) unless line.include?("VNS SELECT OF NEW YORK")
        if invoice
          invoice.check_client {|x, y| errors << [x, y]}
        end
      end
    end
    puts errors
  end
  def self.create_csv(post_date)
    Invoice.where(post_date: post_date).all.each do |inv|
      Provider.all.each {|prov| Ledger.new(prov, inv, post_date) if prov.name == inv.provider}
    end
  end
  class Entry
    attr_accessor :line
    def initialize(line, post_date)
      @line      = line
      @post_date = post_date.strftime("%m/%d/%Y")
    end

    def update_hours
      DB[:invoices].where(:invoice_number => @line[0].to_i).update(:hours => @line[4].to_f)
    end

    def check_client
      fund_id = DB[:clients].where(:name => @line[3]).get(:fund_id)
      if fund_id 
        add_to_db(fund_id) 
      else 
        yield @line[3], @line[2]
      end
    end

    def add_to_db(client_id)
      DB[:invoices].insert(:client_name => @line[3], :invoice_number => @line[0].to_i, :fund_id => client_id, :invoice_amount => @line[5].gsub(/,/, '').to_f, :provider => @line[2], :post_date => @post_date, :hours => @line[4].to_f)
    end
  end
  class Ledger
    attr_accessor :invoice, :provider, :post_date

    def initialize(provider, invoice, post_date)
      @provider, @invoice, @post_date = provider, invoice, post_date
      into_csv
    end

    def into_csv
      CSV.open("#{ARGV[0].gsub(/\//, '-')}_homecare.csv", "a+") do |row|
        row << [1, @invoice.invoice_number, @post_date, @invoice.fund_id, @provider.name, @post_date, "To Record #{ARGV[0]} Billing", "#{@post_date[0..1]}/13#{@provider.abbreviation}", @post_date, "To Rec for W/E #{ARGV[1]} Billing", @provider.fund,       @provider.account,             '', '',          '',@invoice.invoice_amount,                          '']
        row << [2, @invoice.invoice_number, @post_date, @invoice.fund_id, @provider.name, @post_date, "To Record #{ARGV[0]} Billing", "#{@post_date[0..1]}/13#{@provider.abbreviation}", @post_date, "To Rec for W/E #{ARGV[1]} Billing", @provider.fund, @provider.debit_account, @provider.fund, '',      'MLTC',                     '',     @invoice.invoice_amount]
      end
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

# Cycle.import_to_db("#{ARGV[0]}")
Cycle.create_csv("#{ARGV[0]}")