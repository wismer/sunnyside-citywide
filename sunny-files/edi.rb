require 'fileutils'
module Sunnyside
  def self.edi_parser
    print "checking for new files...\n"
    Dir.entries('./835/').reject{|x| !x.include?('.txt') || Filelib.map(:filename).include?(x) }.each do |file|
      data      = File.open('./835/'+file)
      edi_data  = data.read.split(/~CLP\*/)
      edi       = Edi.new(edi_data)
      print "#{file}\n"
      edi.check_type_and_number
      edi.separate_claims_from_services!
      edi.parse_claim_header(file)
      edi.save_payment_to_db(file)
      Filelib.insert(filename: file, created_at: Time.now, purpose: 'EDI Import', file_type: '835 Remittance')
      data.close
      FileUtils.mv("835/#{file}", "835/archive/#{file}")
    end
  end
  class Edi
    attr_reader :header, :check_number
    def initialize(data)
      @header, @claims = data[0], data.drop(1)
    end

    def check_type_and_number
      if header[/(?<=\*C\*)ACH/] == 'ACH'
        @type         = 'EFT Wire Transfer'
        @check_number = header[/(?<=~TRN\*\d\*)\w+/]
        @check_amount = header[/(?<=~BPR\*\w\*)[0-9\.\-]+/]
      elsif header[/(?<=\*C\*)CHK/] == 'CHK'
        @type         = 'Physical Check Issued'
        @check_number = header[/(?<=~TRN\*\d\*)\w+/]
        @check_amount = header[/(?<=~BPR\*\w\*)[0-9\.\-]+/]
      else
        @type         = 'NON-PAYMENT'
        @check_number = '0'
      end
    end

    def check
      if check_number.include?('E') # E for Fidelis
        check_number[/\d+[A-Z]+(\d+)/, 1] 
      else
        check_number
      end
    end

    def separate_claims_from_services!
      @claims.map!{|clm| clm.split(/~(?=SVC)/)}
    end

    def parse_claim_header(file)
      @claims.each do |clm|
        claim_data = clm[0]
        services   = clm.reject{|x| x !~ /^SVC/}
        claims     = InvoiceHeader.new(claim_data)
        claims.format_data
        claims.add_to_db(check, file)
        claims.get_claim_id(check)
        parse_service(services) {|svc| claims.parse_svc(svc, check)}
      end
    end

    def save_payment_to_db(file)
      provider = Claim.where(check_number: @check_number).get(:provider) || 'SENIOR HEALTH PARTNERS'
      Payment.insert(provider: provider, filename: file, type: @type, check_total: @check_amount, check_number: @check_number, import_status: false, claim_count: claim_count(file))
    end

    def claim_count(file)
      return Claim.where(ref_file: file).count
    end

    def parse_service(services)
      services.map{|x| x.split(/~/).reject{|x| x !~ /CAS|SVC|DTM/}}.each {|svc| yield svc}
    end
  end

  class InvoiceHeader < Edi
    attr_accessor :claim_number, :invoice_number
    def initialize(claim)
      @invoice_number, @response_code, @amt_charged, @amt_paid, @whatever, @claim_number = claim.match(/^([\w\.]+)\*(\d+)\*([0-9\.\-]+)\*([0-9\.\-]+)\*([0-9\.\-]+)?\*+\w+\*(\w+)/).captures
      # @client_last, @client_first, @client_middle, @member_id                            = claim.match(/~NM1\*QC\*\d+\*(\w+)\*(\w+)\*(\w)?\*+MI\*(\d+)/).captures
    end

    def format_data
      @invoice_number         = @invoice_number[/^\w+/].gsub(/[OLD]/, 'O' => '0', 'D' => '8', 'L' => '1').gsub(/^0/, '')[0..5].to_i
      @amt_paid, @amt_charged = @amt_paid.to_f, @amt_charged.to_f
    end

    def get_claim_id(check)
      @claim_id = Claim.where(invoice_number: @invoice_number, check_number: check).get(:id)
    end

    def parse_svc(service, check_number)
      if service.length == 2
        svc = Detail.new(service[0], service[1])
      elsif service.length > 2
        svc = Detail.new(service[0], service[1])
        svc.set_denial(service[2])
      end
      svc.display(@invoice_number)
      svc.save_to_db(@invoice_number, check_number, @claim_id)
    end

    def prov
      Invoice.where(invoice_number: @invoice_number).get(:provider)
    end

    def add_to_db(check, file)
      Claim.insert(provider: prov, invoice_number: @invoice_number, amount_charged: @amt_charged, amount_paid: @amt_paid, check_number: check, control_number: @claim_number, denial_reason: @response_code, ref_file: file)
    end
  end

  class Detail < Edi

    attr_reader :billed, :paid
    def initialize(service, date, denial_reason=nil, denial_code=nil)
      @service_code, @billed, @paid, @units = service.match(/HC:([A-Z0-9\:]+)\*([0-9\.\-]+)\*([0-9\.\-]+)?\**([0-9\-]+)?/).captures
      @date = Date.parse(date[/\d+$/])
    end

    def display(inv)
      print "#{inv} #{@service_code} #{@date} #{client(inv)} #{denial}\n"
    end

    def client(inv)
      Invoice.where(invoice_number: inv).get(:client_name)
    end

    def denial
      (billed.to_f - paid.to_f).round(2) if billed > paid
    end

    def set_denial(denial)
      @denial_reason = set_code(denial[/\d+/])
    end

    def save_to_db(invoice, check, claim_id)
      Service.insert(invoice_number: invoice, service_code: @service_code, units: @units.to_f, amount_charged: @billed.to_f, amount_paid: @paid.to_f, denial_reason: @denial_reason, dos: @date, check_number: check, claim_id: claim_id)
    end

    def set_code(code)
      case code
      when '125' then return 'Submission/billing error(s). At least one Remark Code must be provided'
      when '140' then return 'Patient/Insured health identification number and name do not match.'
      when '31'  then return 'INVALID MEMBER ID'
      when '62'  then return 'PAID AUTHORIZED UNITS'
      when '96'  then return 'NO AUTHORIZATION FOR DOS'
      when '146' then return 'DIAGNOSIS WAS INVALID FOR DATES LISTED'
      when '197' then return 'Precertification/authorization/notification absent'
      when '198' then return 'Precertification/authorization exceeded'
      when '199' then return 'Revenue code and Procedure code do not match'
      when '9'   then return 'DIAGNOSIS ISSUE'
      when '15'  then return 'AUTHORIZATION MISSING/INVALID'
      when '18'  then return 'Exact Duplicate Claim/Service'
      when '19'  then return 'Expenses incurred prior to coverage'
      when '27'  then return 'Expenses incurred after coverage terminated'
      when '29'  then return 'Timely Filing'
      when '39'  then return 'Services denied at the time authorization/pre-certification was requested'
      when '45'  then return 'Charge exceeds fee schedule/maximum allowable'
      when '16'  then return 'Claim/service lacks information which is needed for adjudication'
      when '50'  then return 'These are non-covered services because this is not deemed a medical necessity by the payer'
      when '192' then return 'Non standard adjustment code from paper remittance'
      when '181' then return 'Procedure code was invalid on the date of service'
      when '182' then return 'Procedure modifier was invalid on the date of service'
      when '204' then return 'This service/equipment/drug is not covered under the patients current benefit plan'
      when '151' then return '151 Payment adjusted because the payer deems the information submitted does not support this many/frequency of services'
      when '177' then return 'Patient has not met the required eligibility requirements'
      when '109' then return 'Claim/service not covered by this payer/contractor. You must send the claim/service to the correct payer/contractor.'
      else
        return "#{code} is UNIDENTIFIED"
      end
    end
  end
end