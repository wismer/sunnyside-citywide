require "money"
require "pp"
module Sunnyside
  class Reporter
    def initialize
      @claim_data    = []
      @service_data  = []
      @takeback      = []
      @takeback_svc  = []
      enter_provider
    end

    def enter_provider
      print "Enter provider name for list of checks: "
      provs        = Provider.where(Sequel.ilike(:name, "#{gets.chomp}%")).map(:credit_account)
      Payment.where(provider_id: provs).all.each {|x| pp "#{x.id} #{x.check_number}"}
      select_check
    end

    def select_check
      print "Enter in Check Number or type ALL for all checks: "
      @check       = gets.chomp
      @provider_id = claims.get(:provider_id)
      verify_check
    end

    def verify_check
      claims.count > 0 ? generate_tables : enter_provider
    end

    def claims(inv=nil)
      if inv
        Claim.where(payment_id: @check, invoice_id: inv)
      else
        Claim.where(payment_id: @check)
      end
    end

    # Gathers all unique invoice numbers involved with the check number
    # then checks to see if there is more than 1 claim with that invoice number
    # if true, the invoice number gets passed to a special table creation method
    # if false, the invoice number gets passed to a regular table creation method

    def generate_tables
      puts 'gen table'
      @invoices = claims.map(:invoice_id).uniq.sort
      @invoices.each do |inv|
        if claims(inv).count > 1
          takeback_table(inv)
        else
          claim_table(inv)
        end
      end
      create_pdf
    end

    def takeback_table(inv)
      @takeback << [inv, client(inv), claims(inv).sum(:billed).round(2), claims(inv).sum(:paid).round(2), 'Takeback']
      takeback_services(inv)
    end

    def takeback_claims(pdf)
      pdf.move_down 10
      pdf.text "CLAIMS WITH TAKE BACK VALUES"
      pp "#{@takeback}"
      pdf.table(@takeback)
      pdf.table(@takeback_svc)
    end

    def takeback_services(inv)
      Service.where(invoice_id: inv, payment_id: @check).order(:dos).all.each do |svc|
        @takeback_svc << [svc.dos, Claim[svc.claim_id].control_number, svc.billed, svc.paid, svc.id] 
      end
    end

    def create_pdf
      total    = claims.sum(:paid)
      provider = Provider[@provider_id].name.gsub(/\/\\/, '')
      Prawn::Document.generate("./PDF-REPORTS/#{provider}_CHECK_#{@check}.pdf", :page_layout => :landscape) do |pdf|
        pdf.text "CLAIMS FOR #{Provider[@provider_id].name} - CHECK NUMBER: #{@check} - CHECK TOTAL: #{currency(total)}"
        insert_claim_table(pdf)
        pdf.move_down 10
        # takeback_claims(pdf)
        pdf.move_down 10
      end
    end

    def insert_claim_table(pdf)
      @claim_data.each do |c|
        pdf.move_down 10
        pdf.table([c], 
          :column_widths => [75, 75, 75, 75, 75, 150], 
          :cell_style => {
                          :align => :center,
                          :overflow => :shrink_to_fit,
                          :size => 12,
                          :height => 30
                        }) # SHOULD ONLY HAVE ONE CLAIM
        insert_service_table(c[0], pdf)
      end
    end

    def insert_service_table(claim_id, pdf)
      make_service_table(claim_id)
      pdf.table(
        @service_data, 
        :column_widths => [75, 75, 75, 75, 75, 150], 
        :header => true, 
        :cell_style => { 
                          :align => :center,
                          :size => 8, 
                          :height => 20
                        })
    end

    def claim_table(inv)
      claims(inv).all.each do |clm| 
        @claim_data << [clm.id, client(inv), inv, currency(clm.billed), currency(clm.paid), response_msg(clm.status), clm.control_number]
      end
    end

    def response_msg(msg)
      case msg
      when '1'  then 'CASH PAYMENT'
      when '4'  then 'CLAIM DENIED'
      when '22' then 'TAKE BACK'
      else
        'oop'
      end
    end

    def make_service_table(claim_id)
      @service_data = []
      total = 0.0
      @service_data << ['DATE OF SERVICE', 'SERVICE CODE', 'UNITS', 'BILLED', 'PAID', 'DENIAL REASON']
      services(claim_id).all.each {|svc| 
        @service_data << [svc.dos, svc.service_code, svc.units, currency(svc.billed), currency(svc.paid), svc.denial_reason]
        total += svc.paid
      }
      @service_data << ['TOTAL', '', '', '', currency(total)]
    end

    def currency(amt)
      Money.new(amt*100, 'USD').format
    end

    def services(claim_id)
      Service.where(claim_id: claim_id)
    end

    def client(invoice_number)
      Invoice.where(invoice_number: invoice_number).get(:client_name)
    end
  end

  class ClaimSummary < Report

  end
end