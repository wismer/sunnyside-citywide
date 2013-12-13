require "money"

module Sunnyside
  class Reporter
    def initialize
      @claim_data    = []
      @service_data  = []
      # @claim_data    = [['CLIENT', 'INVOICE NUMBER', 'CLAIM NUMBER', 'BILLED', 'DENIED', 'STATUS CODE']]
    end

    def select_check
      print "Enter in Check Number: "
      @check    = gets.chomp
      @provider = claims.get(:provider)
      verify_check
    end

    def verify_check
      claims.count > 0 ? generate_tables : select_check
    end

    def claims(inv=nil)
      if inv
        Claim.where(check_number: @check, invoice_number: inv)
      else
        Claim.where(check_number: @check)
      end
    end

    # Gathers all unique invoice numbers involved with the check number
    # then checks to see if there is more than 1 claim with that invoice number
    # if true, the invoice number gets passed to a special table creation method
    # if false, the invoice number gets passed to a regular table creation method

    def generate_tables
      puts 'gen table'
      @invoices = claims.map(:invoice_number).sort
      @invoices.each do |inv|
        # if claims(inv).count > 1
        #   takeback_table(inv)
        # else
        claim_table(inv)  
      end
      create_pdf
    end

    def takeback_table(inv)
      
    end

    def create_pdf
      provider = claims.get(:provider)
      total    = Service.where(check_number: @check).sum(:amount_paid).round(2)
      Prawn::Document.generate("#{provider.gsub(/ \/\\/, '_')}_CHECK_#{@check}.pdf", :page_layout => :landscape) do |pdf|
        pdf.text "CLAIMS FOR #{provider} - CHECK NUMBER: #{@check} - CHECK TOTAL: #{currency(total)}"
        @claim_data.each do |c|
          pdf.move_down 10
          pdf.table([c], :column_widths => [75, 75, 75, 75, 75, 150], :cell_style => {
                                                                                            :align => :center,
                                                                                            :overflow => :shrink_to_fit,
                                                                                            :size => 12,
                                                                                            :height => 30
                                                                                          }) # SHOULD ONLY HAVE ONE CLAIM
          pdf.move_down 10
          make_service_table(c[0])
          pdf.table(@service_data, :column_widths => [75, 75, 75, 75, 75, 150], :header => true, :cell_style => 
                                                                                          { 
                                                                                            :align => :center,
                                                                                            :size => 8, 
                                                                                            :height => 20
                                                                                          })
          # pdf.table(@service_data)
        end
      end
    end

    def claim_table(inv)
      claims(inv).exclude(amount_charged: nil).all.each do |clm| 
        @claim_data << [clm.id, client(clm.invoice_number), clm.invoice_number, currency(clm.amount_charged), currency(clm.amount_paid), response_msg(clm.denial_reason), clm.control_number]
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
        @service_data << [svc.dos, svc.service_code, svc.units, currency(svc.amount_charged), currency(svc.amount_paid), svc.denial_reason]
        total += svc.amount_paid
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
end