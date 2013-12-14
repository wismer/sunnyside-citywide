require 'sequel'
require 'csv'

# This is a huge huge mess. There needs to be a way to double check if invoices were not being found in the database, as there is no way to account for them
# The exception for SHP/HFS invoices with the odd naming do not work.
# Needs to account for denial codes

module Parser
  DB = Sequel.connect('sqlite://citywide-db.db')

  def self.get_check_title(file)
    File.open("./835/#{file}") do |title| 
      # yield title.read.match(/(?<=~TRN\*1\*)(\w+)(?=\*)/)
      yield title.read.match(/(?<=\*I\*)([0-9\.]+)|(?<=BPR\*C\*)([0-9\.]+)/)
    end
  end

  def self.open_file(file)
    check_date = file.match(/_(\d+)/).captures
    File.open("./835/#{file}") do |section|
      data  = section.read.split(/~CLP\*/)
      check = Check.new(data[0], check_date)
      check.parse_claims(data.drop(1))
    end
  end

  class Check 
    attr_accessor :sub_total, :total, :payment_type, :check_number, :provider

    def initialize(check_detail, check_date)
      @total, @payment_type, @check_number, @provider = check_detail.match(/BPR\*.\*([0-9.]+)\*.\*(CHK|ACH|NON).+TRN\*.\*(\d+).+PR\*([A-Z ,\.]+)/).captures
      @check_date = Date.parse(check_date.join).strftime("%m/%d/%Y")
    end

    def parse_claims(claim_data)
      claim_data.each do |clm|
        claim = Claim.new(clm)
        claim.format_claims
        claim.push_to_db(@check_number.to_i)
        # claim.identify_denied(@check_number.to_i, @check_date)
      end
      print "\n    CHECK SUMMARY FOR #{@provider}\n"
      print "\n             CHECK NUMBER: #{@check_number}\n"
      print "\n      CHECK TOTAL FROM db: " + Invoice.where(check: @check_number.to_i).sum(:amt_paid).round(2).to_s + "\n"
      print "    CHECK TOTAL FROM FILE: #{@total}\n"
      print "               DIFFERENCE: #{(@total.to_f - Invoice.where(check: @check_number.to_i).sum(:amt_paid)).round(2)}\n"
    end
  end
  class Claim < Check
    attr_accessor :invoice, :status, :amt_paid, :amt_charged, :claim_no
    def initialize(claim_summary)
      @invoice, @status, @amt_charged, @amt_paid, @claim_no, @details = claim_summary.match(/(\w+)\*(\d+)\*([0-9\.\-]+)\*([0-9\.\-]+)\*\*..\*(\d+)(.+)/).captures
    end

    def format_claims
      @invoice, @amt_charged, @amt_paid = format_invoice, amt_charged.to_f, amt_paid.to_f 
    end
 
    def format_invoice
      return self.invoice.gsub(/[OLD]/, 'O' => '0', 'D' => '8', 'L' => '1').gsub(/^0/, '')[0..5].to_i # Usually fixes the SHP errors, but not all the time.
    end

    def invoice_query
      Invoice.where(invoice_number: @invoice)
    end

    def push_to_db(check_number)
      invoice_query.update(claim_number: @claim_no)
    end
  end

  class Detail < Claim
    def initialize(service_code, amt_paid, amt_charged, units)
      @service_code, @amt_paid, @amt_charged, @units = service_code, amt_paid, amt_charged, units
    end

    def show_details(invoice)
      # puts invoice_query.get(:invoice_number)
      print "#{invoice}: #{@service_code} #{@amt_paid} #{@units}\n"
    end

    def service(invoice, date, reason)
      puts Service.where(invoice_number: invoice, dos: date).update(denial_reason: reason)
    end

    def set_code(invoice)
      # print "#{invoice} #{@detail[:svc][0]} #{Date.parse(@detail[:dtm][2])}, amt_paid: #{@detail[:dtm][6].to_f}\n"
      # Service.insert(invoice_number: invoice, service_code: @detail[:svc][0], dos: Date.parse(@detail[:dtm][2]), amt_paid: @detail[:dtm][6].to_f)
      # name = Invoice.where(invoice_number: invoice).get(:client_name)
      date = Date.parse(@detail[:dtm][2])
      case @detail[:cas][2]
      when '96'  then service(invoice, date, 'NO AUTHORIZATION FOR DOS')
      when '197' then service(invoice, date, "Precertification/authorization/notification absent")
      when '198' then service(invoice, date, "Precertification/authorization exceeded")
      when '199' then service(invoice, date, "Revenue code and Procedure code do not match")
      when '9'   then service(invoice, date, "DIAGNOSIS ISSUE")
      when '15'  then service(invoice, date, "AUTHORIZATION MISSING/INVALID")
      when '18'  then service(invoice, date, "Exact Duplicate Claim/Service")
      when '19'  then service(invoice, date, "Expenses incurred prior to coverage")
      when '27'  then service(invoice, date, "Expenses incurred after coverage terminated")
      when '29'  then service(invoice, date, "Timely Filing")
      when '39'  then service(invoice, date, "Services denied at the time authorization/pre-certification was requested")
      when '45'  then service(invoice, date, "Charge exceeds fee schedule/maximum allowable")
      else
        print "#{@detail[:cas]} is UNIDENTIFIED\n"
      end
      # puts Service.where(invoice_number: invoice).get(:client_name)
    end
  end
  class Service < Sequel::Model; end
  class Invoice < Sequel::Model; end
  class Provider < Sequel::Model; end
end


        # puts "#{invoice_query.get(:client_name)} -> Invoice#: #{@invoice} CHARGED: #{@amt_charged}, PAID: @amt_paid, CLAIM#: #{@claim_no}\n"
