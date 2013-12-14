module Sunnyside
  class Denial
    def initialize
      @denied = []
    end

    def claims
      Claim.where(check_number: @res)
    end

    def invoice(inv)
      Invoice.where(invoice_number: inv) || 0.0
    end

    def show_checks_with_denied_claims_by_provider
      Claim.map(:provider).uniq.each_with_index do |prov, ind|
        print "#{ind+1}: #{prov}\n"
      end
      print "select provider: "
      provider = gets.chomp
      show_denials_by_provider_check(provider)
    end

    def show_denials_by_provider_check(provider)
      checks = Claim.where(Sequel.ilike(:provider, "#{provider}%")).exclude(to_csv: true).map(:check_number).uniq
      checks.each {|x| print "CHECK: #{x} - #{Service.where(check_number: x).exclude(denial_reason: nil).count} claims with possible denials\n"}
      print "Type in the check to export denied services to CSV format or type ALL to process all displayed: "
      @res = gets.chomp
      if @res.upcase == 'ALL'
        checks.each {|x| 
          @res = x
          filter
          to_csv if filtered?
        }
        show_checks_with_denied_claims_by_provider
      elsif @res == ''
        print "Check number or ALL answer required.\n"
        show_denials_by_provider_check(provider)
      else
        filter
        to_csv if filtered?
        show_denials_by_provider_check(provider)
      end
      # claim.where(Sequel.ilike(:provider, "#{provider}%")).all.each {|x| print "#{x.check_number} #{x.invoice_number} #{x.amount_paid - x.amount_charged}\n"}
    end

    def total_by_invoice(inv)
      yield claims.where(invoice_number: inv).sum(:amount_paid)
    end

    def filter
      claims.map(:invoice_number).uniq.each do |inv| # all invoices in check
        # total_by_invoice(inv) {|x| print "#{claims.where(invoice_number: inv).count} #{inv} #{x}\n"}
        if claims.where(invoice_number: inv).sum(:amount_paid) < invoice(inv).get(:amount) # all invoices of check that's total is less than the amount originally charged
          puts inv
          @denied << service(inv)
        end
      end
    end

    def service(inv)
      Service.where(invoice_number: inv, check_number: @res).exclude(denial_reason: nil)
    end

    def filtered?
      @denied.size > 0
    end

    def prov(inv)
      invoice(inv).get(:provider).gsub(/\//, '')
    end

    def client(inv)
      invoice(inv).get(:client_name)
    end

    def control(id)
      Claim.where(id: id).get(:control_number)
    end

    def mark_exported(id)
      Claim.where(id: id).update(to_csv: true)
    end

    def to_csv
      @denied.each do |services|
        services.all.each do |svc|
          CSV.open("denied-#{prov(svc.invoice_number)}", 'a+') {|row| row << [prov(svc.invoice_number), svc.invoice_number, client(svc.invoice_number),svc.service_code, svc.dos, svc.amount_paid, svc.amount_charged, svc.denial_reason, control(svc.claim_id), svc.check_number]}
          mark_exported(svc.claim_id)
        end
      end
      @denied = []
    end
  end
end