require 'sequel'
require 'csv'
module Parser
  DB     = Sequel.connect('sqlite://citywide-db.db')
  class Query

    def show_invoices_with_denials(check)
      invoice_query(check).all.each {|x| print "#{x.invoice_number} UNPAID: #{x.invoice_amount - x.amt_paid}\n" if (x.invoice_amount - x.amt_paid) > 0}
    end

    def update_invoice(check)
      invoice_query(check).all.each do |inv|
        amt_paid = service_sum(check, inv.invoice_number)
        inv.update(amt_paid: amt_paid)
      end
    end

    def service_sum(check, invoice)
      Service.where(check: check, invoice_number: invoice).sum(:amt_paid).round(2)
    end

    def invoice_query(check)
      Invoice.where(check: check)
    end

    def claim_number(check, inv)
      return Invoice.where(check: check, invoice_number: inv).get(:claim_number)
    end

    def inv_name(inv)
      return Invoice.where(invoice_number: inv).get(:client_name)
    end

    def services_with_denials(check)
      CSV.open("./denial-eops/#{check.provider}-#{check.check_number}.csv", 'a+') {|row| row << %w{invoice_number client_name dos service_code amount_charged amount_paid denial_reason claim_number check_number}}
      Service.where(check: check.check_number).all.each {|svc| push_to_csv(svc, check.check_number, check.provider) if !svc.denial_reason.nil?}
    end

    def push_to_csv(svc, check, provider)
      print "#{svc.check}, #{svc.dos} #{svc.denial_reason} #{svc.invoice_number}\n"
      CSV.open("./denial-eops/#{provider}-#{check}.csv", 'a+') {|row| row << [svc.invoice_number, inv_name(svc.invoice_number), svc.dos, svc.service_code, svc.amount, svc.amt_paid, svc.denial_reason, claim_number(check, svc.invoice_number), check]}
    end

    def view_edi(check_number)
      Invoice.where(check: check_number).all.each {|inv| print "#{inv.invoice_number}: CHG: #{inv.invoice_amount} PD: #{inv.amt_paid}\n"}
    end

    def view_invoice(invoice)
      print "#{Invoice.where(invoice_number: invoice).get(:claim_number)}\n"
      Service.where(invoice_number: invoice).all.each {|svc| print "        #{svc.dos}: #{svc.amount} #{svc.amt_paid}\n"}
    end

    def view_eop_by_check
      Check.all.each_with_index {|chk, ind| print "#{ind+1}.) #{chk.provider} Check #: #{chk.check_number}, Posted: #{chk.post_date}\n"} # reject {|chk| chk.services_denied == 0}
    end

    def eop_by_provider

    end

    def contain_denials?(check)
      invoice_query(check).sum(:invoice_amount) != invoice_query(check).sum(:amt_paid)
    end

    def process_by_check(check)
      print "#{check.provider} contains #{invoice_query(check.check_number).count} claims with #{check.services_denied} service date errors. OK to process? (Y or N): "
      services_with_denials(check) if affirmative? && contain_denials?(check.check_number)
    end

    def affirmative?
      return true if gets.chomp.downcase == 'y' 
    end

    def show_options
      print "1.) View electronic EOP's\n"
      print "2.) Create EOP's by check #\n"
      print "3.) Create EOP's by provider name\n"
      print "4.) EXIT\n"
      print "    Enter #: "
      return gets.chomp
    end

    def view_errors(check)
      print ""
    end

    def find_service(check)
      Service.where(check: check)
    end

    def update_checks
      # Check.all.each {|chk| print "#{find_service(chk.check_number).exclude(denial_reason: nil).count}\n"}
      Check.all.each do |chk|
        prov = invoice_query(chk.check_number).get(:provider)
        print "#{prov}\n"
        chk.update(provider: prov) if chk.provider.nil?
        count = find_service(chk.check_number).exclude(denial_reason: nil).count
        chk.update(services_denied: count)
      end
    end
  end
  class Claim
    attr_accessor :invoice
    def initialize(header, body=nil, check_number, check_date)
      @header, @body, @check_number, @check_date = header, body, check_number, check_date
    end

    def add_check
      Invoice.where(invoice_number: @invoice).update(check: @check_number, check_date: @check_date, claim_number: @claim)
    end

    def service
      Service.where(invoice_number: @invoice_number)
    end

    def parse_header
      @invoice = @header[/^\w+/].gsub(/[OLD]/, 'O' => '0', 'D' => '8', 'L' => '1').gsub(/^0/, '')[0..5].to_i
      @claim   = @header[/(?<=HM\*)\d+/]
    end

    def parse_body
      @body.map!{|x| x.split(/~/).reject{|x| x !~ /CAS|SVC|DTM/}}.each {|svc| parse_service(svc)}
    end

    def parse_service(service)
      if service.length == 2
        svc = Detail.new(service[0], service[1])
      elsif service.length > 2
        svc = Detail.new(service[0], service[1])
        svc.set_denial(service[2])
      end
      svc.display
      svc.save_to_db(@invoice.to_i, @check_date, @check_number)
    end

    def add_invoice(inv)
      Invoice.where(:invoice_number => inv.to_i).all.each {|x| yield x}
    end

    def check_provider(prov)
      Provider.all.each {|provider| return provider if provider.name == prov}
    end

    def create_csv(receipt_num, post_date, invoice, prov)
      CSV.open("./ledger-files/EDI-MISC-citywide-import.csv", "a+") do |row| # #{post_date.gsub(/\//, '-')}-
        row << [1, receipt_num, post_date, invoice.fund_id, invoice.invoice_number, invoice.invoice_number, "#{post_date[3..4]}/13#{prov.abbreviation}", post_date, invoice.invoice_number, prov.fund, prov.account,'','','', 0,  invoice.invoice_amount]
        row << [2, receipt_num, post_date, invoice.fund_id, invoice.invoice_number, invoice.invoice_number, "#{post_date[3..4]}/13#{prov.abbreviation}", post_date, invoice.invoice_number,       100,         1000,'','','', invoice.invoice_amount,    0]
        row << [3, receipt_num, post_date, invoice.fund_id, invoice.invoice_number, invoice.invoice_number, "#{post_date[3..4]}/13#{prov.abbreviation}", post_date, invoice.invoice_number, prov.fund,         3990, '', '', '', invoice.invoice_amount, 0]
        row << [4, receipt_num, post_date, invoice.fund_id, invoice.invoice_number, invoice.invoice_number, "#{post_date[3..4]}/13#{prov.abbreviation}", post_date, invoice.invoice_number,       100,         3990, '', '', '', 0, invoice.invoice_amount]
      end       
    end
  end

  class Detail < Claim
    def initialize(service, date, denial_reason=nil, denial_code=nil)
      @service_code, @billed, @paid, @units = service.match(/HC:([A-Z0-9\:]+)\*([0-9\.\-]+)\*([0-9\.\-]+)?\**([0-9\-]+)?/).captures
      @date = Date.parse(date[/\d+$/])
    end

    def set_denial(denial)
      @denial_reason = set_code(denial[/\d+/])
    end

    def display
      print "#{@service_code}, #{@billed}, #{@paid}, #{@units} #{@date} #{@denial_reason}\n"
    end

    def save_to_db(invoice, date, check)
      Service.insert(invoice_number: invoice, service_code: @service_code, units: @units.to_f, amount: @billed.to_f, amt_paid: @paid.to_f, denial_reason: @denial_reason, dos: @date, check_date: date, check: check)
    end
    
    def set_code(code)
      case code
      when '96'  then return "NO AUTHORIZATION FOR DOS"
      when '197' then return "Precertification/authorization/notification absent"
      when '198' then return "Precertification/authorization exceeded"
      when '199' then return "Revenue code and Procedure code do not match"
      when '9'   then return "DIAGNOSIS ISSUE"
      when '15'  then return "AUTHORIZATION MISSING/INVALID"
      when '18'  then return "Exact Duplicate Claim/Service"
      when '19'  then return "Expenses incurred prior to coverage"
      when '27'  then return "Expenses incurred after coverage terminated"
      when '29'  then return "Timely Filing"
      when '39'  then return "Services denied at the time authorization/pre-certification was requested"
      when '45'  then return "Charge exceeds fee schedule/maximum allowable"
      when '16'  then return "Claim/service lacks information which is needed for adjudication"
      when '50'  then return "These are non-covered services because this is not deemed a 'medical necessity' by the payer"
      when '192' then return "Non standard adjustment code from paper remittance"
      when '181' then return "Procedure code was invalid on the date of service"
      when '182' then return "Procedure modifier was invalid on the date of service"
      when '204' then return "This service/equipment/drug is not covered under the patients current benefit plan"
      when '151' then return "151 Payment adjusted because the payer deems the information submitted does not support this many/frequency of services"
      when '177' then return "Patient has not met the required eligibility requirements"
      when '109' then return "Claim/service not covered by this payer/contractor. You must send the claim/service to the correct payer/contractor."
      else
        print "#{code} is UNIDENTIFIED\n"
      end
    end
  end
  class Service < Sequel::Model; end
  class Invoice < Sequel::Model; end
  class Client < Sequel::Model; end
  class Provider < Sequel::Model; end
  class Check < Sequel::Model; end
end

