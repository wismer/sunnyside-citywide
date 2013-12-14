# !!!WARNING!!!
# NOT COMPLETELY UP TO DATE - VERIFY THE IMPORT FUNCTION WORKS FIRST BEFORE IMPORTING AN ENTIRE WEEKS WORTH OF INVOICES
# !!!WARNING!!!
require "prawn"
require "csv"
require_relative 'list.rb'
module Cycle
  @@totals = {}
  PROVIDER_LIST_CITYWIDE.keys.each {|provider| @@totals[provider] = 0}

  def self.read_files(file)
    PDF::Reader.new(file).pages.each {|page| yield page.raw_content}
  end

  def testing
    print "123\n"
  end

  def self.subtotal(provider, amount)
    @@totals[provider] += amount.to_f.round(2) if @@totals.keys.include?(provider)
  end

  def self.total
    @@totals.each do |provider, total| 
      CSV.open("sum-total_#{ARGV[2].gsub(/\//,'-')}.csv", "a+") {|row| row << [provider, total.to_f.round(2)]}
    end
  end
  class Invoice
    attr_accessor :provider, :amount, :client, :invoice

    def initialize(invoice, post_date, provider, client, amount, client_id=nil, detail=nil)
      @invoice    = invoice
      @post_date  = post_date
      @provider   = provider
      @client     = client
      @amount     = amount
    end

    def match_client
      if CITYWIDE_CLIENT_LIST[:clients].keys.include?(@client) 
        @client_id = CITYWIDE_CLIENT_LIST[:clients][@client]
      else
        print "#{@client}: #{@provider}\n" if @provider != "VISITING NURSE SERVICE"
      end
    end

    def match_provider
      @provider = 'PRIVATE' if !PROVIDER_LIST_CITYWIDE.keys.include?(@provider) && @provider != "VISITING NURSE SERVICE"
      PROVIDER_LIST_CITYWIDE.each {|name, detail| @detail = detail if @provider == name}
    end

    def create_csv(file)
      @provider = 'AMERIGROUP' if @provider == 'AMERIGROUP 2'
      CSV.open(file, "a+", headers: true) do |row|
        row << [1, @invoice, @post_date, @client, @client_id, @provider, @post_date, "To Record #{ARGV[1]} Billing", "#{ARGV[2]}#{@detail[:abbrev]}", @post_date, "To Rec for W/E #{ARGV[3]} Billing", @detail[:fund],       @detail[:account],            '', '', @amount,     '']
        row << [2, @invoice, @post_date, @client, @client_id, @provider, @post_date, "To Record #{ARGV[1]} Billing", "#{ARGV[2]}#{@detail[:abbrev]}", @post_date, "To Rec for W/E #{ARGV[3]} Billing", @detail[:fund], @detail[:debit_account], @detail[:cc1], '',      '',@amount]
      end
    end
    def add_invoice(inv)
      yield Detail.new(inv)
    end
  end
end

Cycle.read_files("#{ARGV[0]}.pdf") do |page|
  page.scan(/(\d{6})\s+(\d+\/\d+\/\d+)\s+\d+\s+(.{3,30})\s+(.{3,15})\s+\d+\.\d+\s+(\d,?\d+\.\d+)/) do |line|
    entry = Cycle::Invoice.new(line[0], line[1], line[2].strip, line[3].strip, line[4].gsub(/,/, ''))
    entry.match_client
    entry.match_provider
    # invoice.check_nil
    entry.create_csv("#{ARGV[0]}.csv") unless entry.provider == 'VISITING NURSE SERVICE'
    Cycle.subtotal(entry.provider, entry.amount)
  end
end 
Cycle.total

# ruby cycle.rb <filename> (without extension) <import date> <batch - mm/yy> <week ending date - mm/dd/yy>
# TO DO 
# 1.) put in functionality for choosing homecare or citywide