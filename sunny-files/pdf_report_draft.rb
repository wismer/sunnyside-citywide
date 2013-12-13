require "money"
module Sunnyside
  class Reporter
    attr_reader :check, :claims, :services
    def initialize(check)
      @check         = check
      @claims        = Claim.where(check_number: check)
      @services      = Service.where(check_number: check)
      if claims.count > 0 
        create_pdf
      else
        Reporter.new(gets.chomp)
      end
    end

    def provider
      claims.get(:provider).gsub(/ \/\\/, '_')
    end

    def takeback_present?
      claims.where(denial_reason: '22').count > 0
    end

    def denials_present?
      claims.where('amount_charged > amount_paid').exclude(denial_reason: '22').count > 0 
    end

    def create_pdf
      Prawn::Document.generate("#{provider}_CHECK_#{check}.pdf", :page_layout => :landscape) do |pdf| 
        report = ReportPDF.new(pdf, :claim_data => claims, :service_data => services, :provider => provider, :check => check)
        report.create_check_header
        if takeback_present?
          report.takeback_table
        elsif denials_present?
          report.denial_table
        else
          report.claim_table
        end
      end
    end
  end
  class ReportPDF
    attr_reader :pdf, :claims, :services, :provider, :check
    def initialize(pdf, data = {})
      @pdf      = pdf
      @claims   = data[:claim_data]
      @services = data[:service_data]
      @provider = data[:provider]
      @check    = data[:check]
    end

    def create_check_header
      pdf.text "CLAIMS FOR #{provider} - CHECK NUMBER: #{check} - CHECK TOTAL: #{currency(check_total)}"
      pdf.move_down 20
    end

    def check_total
      services.sum(:amount_paid)
    end

    def currency(amt)
      Money.new(amt * 100, 'USD').format
    end

    def takebacks
      claims.where(denial_reason: '22')
    end

    def takeback_table
      takeback_header
      takebacks.all.each { |clm| claim_header(clm) }
    end

    def denials
      claims.exclude(denial_reason: '22').where('amount_charged > amount_paid')
    end

    def denial_table
      pdf.text 'CLAIMS WITH DENIALS'
      pdf.move_down 10
    end

    def takeback_header
      pdf.text 'ADJUSTED CLAIMS'
      pdf.move_down 10
    end

    def table_create
      pdf.text 'asdasds'
      and_this_too_please
    end

    def client(inv)
      Invoice.where(invoice_number: inv).get(:client_name)
    end

    def claim_header(claim)
      pdf.move_down 10
      claim_data = [[claim.control_number, client(claim.invoice_number), claim.invoice_number, currency(claim.amount_charged), currency(claim.amount_paid), claim.denial_reason]]
      pdf.table(claim_data, :column_widths => [85, 75, 75, 75, 75, 150], :cell_style => {
                                                                                        :align => :center,
                                                                                        :overflow => :shrink_to_fit,
                                                                                        :size => 12,
                                                                                        :height => 30
                                                                                      }) # SHOULD ONLY HAVE ONE CLAIM
      pdf.move_down 10
      create_service_table(claim.id)
    end

    def service_data(id)
      services.where(claim_id: id).map { |svc| ['', svc.dos, svc.service_code + svc.mod_1, svc.units, svc.amount_charged, svc.amount_paid, svc.denial_reason] }
    end

    def create_service_table(id)
      pdf.table(service_data(id), :column_widths => [85, 75, 75, 75, 75, 150], :cell_style => {
                                                                                  :align => :center,
                                                                                  :overflow => :shrink_to_fit,
                                                                                  :size => 12,
                                                                                  :height => 30
                                                                                }) # SHOULD ONLY HAVE ONE CLAIM
    end

    def claim_table
      claims.exclude(denial_reason: ['22', '4']).all.each { |clm| claim_header(clm) }
    end
  end

  #   class CreatePDF
  #     attr_reader :pdf

  #     def initialize(provider, check)
  #       @pdf   = 
  #       @entry = 
  #     end

  #   def create_pdf
  #     Prawn::Document.generate("#{provider.gsub(/ \/\\/, '_')}_CHECK_#{@check}.pdf", :page_layout => :landscape) do |pdf|
  #       pdf.text "CLAIMS FOR #{provider} - CHECK NUMBER: #{@check} - CHECK TOTAL: #{currency(total)}"
  #       @claim_data.each do |c|
  #         pdf.move_down 10
  #         pdf.table([c], :column_widths => [75, 75, 75, 75, 75, 150], :cell_style => {
  #                                                                                           :align => :center,
  #                                                                                           :overflow => :shrink_to_fit,
  #                                                                                           :size => 12,
  #                                                                                           :height => 30
  #                                                                                         }) # SHOULD ONLY HAVE ONE CLAIM
  #         pdf.move_down 10
  #         make_service_table(c[0])
  #         pdf.table(@service_data, :column_widths => [75, 75, 75, 75, 75, 150], :header => true, :cell_style => 
  #                                                                                         { 
  #                                                                                           :align => :center,
  #                                                                                           :size => 8, 
  #                                                                                           :height => 20
  #                                                                                         })
  #         # pdf.table(@service_data)
  #       end
  #     end
  #   end

  #   def claim_table(inv)
  #     claims(inv).exclude(amount_charged: nil).all.each do |clm| 
  #       @claim_data << [clm.id, client(clm.invoice_number), clm.invoice_number, currency(clm.amount_charged), currency(clm.amount_paid), response_msg(clm.denial_reason), clm.control_number]
  #     end
  #   end

  #   def response_msg(msg)
  #     case msg
  #     when '1'  then 'CASH PAYMENT'
  #     when '4'  then 'CLAIM DENIED'
  #     when '22' then 'TAKE BACK'
  #     else
  #       'oop'
  #     end
  #   end

  #   def make_service_table(claim_id)
  #     @service_data = []
  #     total = 0.0
  #     @service_data << ['DATE OF SERVICE', 'SERVICE CODE', 'UNITS', 'BILLED', 'PAID', 'DENIAL REASON']
  #     services(claim_id).all.each {|svc| 
  #       @service_data << [svc.dos, svc.service_code, svc.units, currency(svc.amount_charged), currency(svc.amount_paid), svc.denial_reason]
  #       total += svc.amount_paid
  #     }
  #     @service_data << ['TOTAL', '', '', '', currency(total)]
  #   end

  #   def currency(amt)
  #     Money.new(amt*100, 'USD').format
  #   end

  #   def services(claim_id)
  #     Service.where(claim_id: claim_id)
  #   end

  #   def client(invoice_number)
  #     Invoice.where(invoice_number: invoice_number).get(:client_name)
  #   end
  # end
end