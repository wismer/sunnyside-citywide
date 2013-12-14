require 'sequel'
require 'csv'

# This is a huge huge mess. There needs to be a way to double check if invoices were not being found in the database, as there is no way to account for them
# The exception for SHP/HFS invoices with the odd naming do not work.
# Needs to account for denial codes

require_relative 'database.rb'
module Parser
  DB = Sequel.connect('sqlite://citywide-db.db')

  def self.open_file(file)
    File.open("./835/#{file}") do |section|
      data  = section.read.split(/CLP\*/)
      check = Check.new(data[0])
      check.parse_claims(data.drop(1))
      # check.detail do |chk| 
        # print "#{file[0..20]}: #{chk.provider} #{chk.check_number}\n"
        # print "you have selected #{chk.provider}. OK to proceed (Y/N)? Please be aware this is a #{chk.payment_type} file\n"
        # response = gets.chomp
        # data.drop(1).each do |c| 
        #   check.parse_claims
          # check.claim_summary = c # only processes invoice numbers if the payment type is ACH or automatic clearing house
        # end
        # print "The total for this check is #{chk.total}.\n Hit ENTER to return to the menu"
        # response = gets.chomp
        # section.close
        # File.rename("./835/#{file}", "./835/#{chk.provider}-#{chk.check_number}.txt")
      # end
    end
  end

  class Check 
    attr_accessor :sub_total, :total, :payment_type, :check_number, :provider

    def initialize(check_detail)
      @total, @payment_type, @check_number, @provider = check_detail.match(/BPR\*.\*([0-9.]+)\*.\*(CHK|ACH|NON).+TRN\*.\*(\d+).+PR\*([A-Z ,\.]+)/).captures
      @sub_total = 0.0
    end

    def parse_claims(claim_data)
      claim_data.each do |clm|
        claim = Claim.new(clm)
      end
    end

    def detail
      yield self # passes check info back to open_file
    end

    def check_provider(prov)
      Provider.all.each {|provider| return provider if provider.name == prov}
    end

    def add_invoice(inv)
      Invoice.where(:invoice_number => inv.to_i).all.each do |invoice| 
        if !invoice.invoice_number.nil?
          yield invoice
        else
          print "#{invoice} not found in database.\n"
        end
      end
    end

    def claim_summary=(arg)
      claim = Claim.new(arg)
      claim.format_invoice
      @sub_total += claim.amt_paid.to_f
      add_invoice(claim.invoice[0..5]) do |inv|
        print "#{claim.invoice} -> #{inv.invoice_number} #{inv.invoice_amount} - SUBTOTAL: #{@sub_total.round(2)}\n"          
        prov = check_provider(inv.provider)
        to_csv(@check_number, prov, inv)
      end
      CSV.open("#{claim.provider}-denial-claims-#{Time.now.to_s[0..9]}.csv", "a+") {|row| row << [claim.invoice, claim.status, claim.claim_no, claim.amt_paid, claim.amt_charged, claim.amt_paid - claim.amt_charged]} unless claim.status = '1'
    end

    def to_csv(receipt_num, prov, invoice)
      CSV.open("./ledger-files/#{Time.now.to_s[0..9]}-citywide-import.csv", "a+") do |row|
        row << [1, receipt_num, invoice.fund_id, invoice.invoice_number, invoice.invoice_number, "08/13#{prov.abbreviation}", invoice.invoice_number, prov.fund, prov.account,'','','', 0,  invoice.invoice_amount]
        row << [2, receipt_num, invoice.fund_id, invoice.invoice_number, invoice.invoice_number, "08/13#{prov.abbreviation}", invoice.invoice_number,       100,         1000,'','','', invoice.invoice_amount,    0]
        row << [3, receipt_num, invoice.fund_id, invoice.invoice_number, invoice.invoice_number, "08/13#{prov.abbreviation}", invoice.invoice_number, prov.fund,         3990, '', '', '', invoice.invoice_amount, 0]
        row << [4, receipt_num, invoice.fund_id, invoice.invoice_number, invoice.invoice_number, "08/13#{prov.abbreviation}", invoice.invoice_number,       100,         3990, '', '', '', 0, invoice.invoice_amount]
      end
    end
  end

  class Claim < Check
    attr_accessor :invoice, :status, :amt_paid, :amt_charged, :claim_no
    def initialize(claim_summary)
      @invoice, @status, @amt_charged, @amt_paid, @claim_no = claim_summary.match(/(\w+)\*(\d+)\*([0-9\.-]+)\*([0-9\.-]+)\*\*..\*(\d+)/).captures
    end

    def to_s
      "#{@invoice} #{@status} #{@amt_charged} #{@amt_paid} #{@claim_no}\n"
    end

    def format_invoice
      @amt_paid, @amt_charged = self.amt_paid.to_f, self.amt_charged.to_f
      @invoice = self.invoice.gsub(/[OLD]/, 'O' => '0', 'D' => '8', 'L' => '1').gsub(/^0/, '')
    end
  end

  class Detail < Claim
    def initialize(remit)
      @service_code, @dos_charged, @dos_paid, @units, @dos = remit.match
    end
  end
  class Invoice < Sequel::Model; end
  class Provider < Sequel::Model; end
end

files = Dir.entries('./835/').reject{|file| !file.include?('.txt')}
loop do 
  files.each_with_index do |file, index|
    print "#{index}.) #{file}\n"
  end
  print "\n\nSELECT THE FILE YOU WISH TO PROCESS:\n\n"
  response = gets.chomp
  Parser.open_file(files[response.to_i])
end