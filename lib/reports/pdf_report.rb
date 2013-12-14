require "money"
require "pp"
module Sunnyside
  class Reporter
    attr_reader :claim_data, :service_data, :takeback, :takeback_data, :check, :files, :total
    def initialize
      @claim_data     = []
      @service_data   = []
      @takeback       = []
      @takeback_data  = []
      @files          = Dir["PDF-REPORTS/*.pdf"]
    end

    def check_existing
      Payment.all.each do |payment|
        if !files.any? { |file| file.include?(payment.check_number.to_s) } || files.empty?
          @check       = payment.id
          @provider_id = payment.provider_id || 1204
          @total       = payment.check_total || service_sum
          verify_check
        end
      end
    end

    def service_sum
      Service.where(payment_id: @check).sum(:paid)
    end

    def verify_check
      claims.count > 0 ? generate_tables : non_payment
    end

    def non_payment
    end

    def claims(inv=nil)
      if inv
        Claim.where(payment_id: check, invoice_id: inv)
      else
        Claim.where(payment_id: check)
      end
    end

    # Gathers all unique invoice numbers involved with the check number
    # then checks to see if there is more than 1 claim with that invoice number
    # if true, the invoice number gets passed to a special table creation method
    # if false, the invoice number gets passed to a regular table creation method

    def generate_tables
      invoices = claims.map(:invoice_id).uniq.sort
      invoices.each do |inv|
        if claims(inv).count > 1
          takeback_table(inv)
        else
          claim_table(inv)
        end
      end
      create_pdf
    end

    def takeback_table(inv)
      @takeback << [inv, client(inv), '', '', currency(claims(inv).sum(:billed)), currency(claims(inv).sum(:paid)), 'Takeback']
      takeback_services(inv)
    end

    def takeback_claims(pdf)
      pdf.move_down 10
      pdf.table(@takeback, 
        :header        => true,
        :column_widths => [65, 75, 65, 65, 65, 65, 125], 
          :cell_style  => {
                          :align    => :center,
                          :overflow => :shrink_to_fit,
                          :size     => 8,
                          :height   => 20
                         })
      # pdf.table(@takeback_data,
      #   :column_widths => [75, 75, 75, 75, 75, 75, 125], 
      #   :header => true, 
      #   :cell_style => { 
      #                     :align => :center,
      #                     :size => 8, 
      #                     :height => 20
      #                   })
      pdf.move_down 10
      @takeback = []
    end

    def takeback_services(inv)
      sub_total = 0.0
      @takeback << ['DOS', 'Service Code', 'Units', 'Claim #', 'Billed', 'Paid', 'Explanation']
      Service.where(invoice_id: inv, payment_id: check).order(:dos).all.each do |svc|
        reason     = svc.denial_reason || 'None'
        @takeback << [svc.dos, svc.service_code, svc.units, Claim[svc.claim_id].control_number, currency(svc.billed), currency(svc.paid), reason] 
        sub_total     += svc.paid
      end
      @takeback << ['TOTAL', '', '', '', '', currency(sub_total)]
    end

    def opts
      { 
        :layout        => :landscape, 
        :top_margin    => 50, 
        :bottom_margin => 20, 
        :right_margin  => 15,
        :left_margin   => 15
      } 
    end

    def create_pdf
      puts     "#{Provider[@provider_id].name}: #{Payment[check].check_number}"
      provider = Provider[@provider_id].name.gsub(/\/|\\/, '')
      Prawn::Document.generate("./PDF-REPORTS/#{provider}_CHECK_#{Payment[@check].check_number}.pdf", opts) do |pdf|
        pdf.move_down 50
        pdf.text "CLAIMS FOR #{Provider[@provider_id].name} - CHECK NUMBER: #{Payment[@check].check_number} - CHECK TOTAL: #{currency(total)}"
        insert_claim_table(pdf)
        pdf.move_down 10
        if !@takeback.empty?
          pdf.start_new_page
          pdf.text "TAKE BACK CLAIMS"
          takeback_claims(pdf) 
        end
        page_numbering(pdf)
      end
      @takeback   = []
      @claim_data = []
    end

    def page_numbering(pdf)
      pdf.number_pages('Page <page> of <total>', { :at             => [pdf.bounds.right - 150, 0],
                                                   :width          => 150, 
                                                   :align          => :center,
                                                   :start_count_at => 1 
                                                  }
        )
    end

    def insert_claim_table(pdf)
      @claim_data.each do |c|
        pdf.move_down 10
        pdf.table([c], 
          :column_widths => [65, 75, 65, 65, 65, 150], 
          :cell_style => {
                          :align    => :center,
                          :overflow => :shrink_to_fit,
                          :size     => 10,
                          :height   => 30
                        }) # SHOULD ONLY HAVE ONE CLAIM
        insert_service_table(c[0], pdf)
      end
    end

    def insert_service_table(claim_id, pdf)
      make_service_table(claim_id)
      pdf.table(@service_data, table_opts)
    end

    def table_opts
      {
        :column_widths => [65, 75, 65, 65, 65, 150], 
        :header => true, 
        :cell_style => { 
                          :align    => :center,
                          :overflow => :shrink_to_fit,
                          :size     => 8, 
                          :height   => 20
                        }
      }
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
      @service_data << ['TOTAL', '', '', '', currency(total), '']
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