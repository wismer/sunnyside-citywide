require "money"
require "pp"
module Sunnyside

  def self.run_report
    print "Type in the post date (YYYY-MM-DD): "
    post_date = Date.parse(gets.chomp)
    self.check_prompt { |payment| 
      provider = Provider[payment.provider_id]
      report   = Reporter.new(payment, post_date, provider) 
      report.check_header
    }
  end  

  class Reporter
    include Sunnyside
    attr_reader :payment, :claims, :post_date, :provider, :pdf, :total

    def initialize(payment, post_date, provider)
      @provider  = provider
      @payment   = payment
      @post_date = post_date
      @claims    = Claim.where(payment_id: payment.id)
      @pdf       = Prawn::Document.new(:page_layout => :landscape) # generate("#{DRIVE}/sunnyside-files/pdf-reports/#{provider.name}-#{payment.check_number}.PDF", :page_layout => :landscape)
      @total     = Money.new(payment.check_total * 100, 'USD').format
    end

    def check_header
      puts "creating report for #{provider.name} - Check Number: #{payment.check_number} - posted on: #{post_date}"
      pdf.text "CLAIMS FOR #{provider.name} - CHECK NUMBER: #{payment.check_number} - CHECK TOTAL: #{total}"
      pdf.move_down 50

      pdf.text "Claims with payments."

      paid_claims do |clm|
        pdf.move_down 10
        claim = ClaimEOP.new(clm, post_date, pdf, clm.paid, clm.billed)
        claim.create_block
      end

      if claims.where(status: '4').count > 0
        pdf.start_new_page
        pdf.text "Claims with denials."

        denied_claims do |clm|
          pdf.move_down 10
          claim = ClaimEOP.new(clm, post_date, pdf, clm.paid, clm.billed)
          claim.create_block
        end
      end

      if claims.where(status: '22').count > 0
        pdf.start_new_page
        pdf.text "Claims with takebacks."

        takeback_claims do |clm|
          pdf.move_down 10
          claim = ClaimEOP.new(clm, post_date, pdf, clm.paid, clm.billed)
          claim.create_block
        end
      end

      page_numbering

      pdf.render_file("#{DRIVE}/sunnyside-files/pdf-reports/#{provider.name.gsub(/[\.\/]/, '')}-#{payment.check_number}.PDF")
    end

    def page_numbering
      pdf.number_pages('Page <page> of <total>', { :at => [pdf.bounds.right - 150, - 10], :width => 150, :align => :center, :start_count_at => 1 } )
    end

    def denied_claims
      claims.where(status: '4').order(:invoice_id).all.each { |claim| yield claim if !claim.nil?}
    end

    def paid_claims
      claims.where(status: '1').order(:invoice_id).all.each { |claim| yield claim if !claim.nil?}
    end

    def takeback_claims
      claims.where(status: '22').order(:invoice_id).all.each { |claim| yield claim if !claim.nil?}
    end
  end

  class ClaimEOP < Reporter
    attr_reader :claim, :post_date, :pdf, :claim_row, :opts, :services

    def initialize(claim, post_date, pdf, paid, billed)
      @claim     = claim
      @claim_row = [claim.invoice_id, 'Date', Client[claim.client_id].client_name, 'Units', currency(billed), currency(paid), claim.control_number]
      @post_date = post_date
      @pdf       = pdf
      @services  = Service.where(claim_id: claim.id).all.map { |svc| ['', svc.dos, svc.service_code, svc.units, currency(svc.paid), currency(svc.billed), svc.denial_reason] }
      @opts      = { :column_widths => [85, 75, 75, 75, 75, 145], :cell_style => {:align => :center, :overflow => :shrink_to_fit, :size => 12, :height => 30 } }
    end

    def create_block
      pdf.table([claim_row], opts)
      pdf.move_down 10
      pdf.table(services, opts)
    end

    def currency(amt)
      Money.new(amt*100, 'USD').format
    end
  end
end