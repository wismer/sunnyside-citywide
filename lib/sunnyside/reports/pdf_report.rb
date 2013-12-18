require "money"
require "pp"
module Sunnyside

  def self.run_report
    print "Type in the check number in order to create the PDF file: "
    check   = gets.chomp
    print "Now enter the date the check was posted to FUND EZ: "
    postted = gets.chomp
    Reporter.new(check, posted).pdf_report
  end  
  class Reporter
    include Sunnyside
    attr_reader :check, :posted, :check_number

    def initialize(check, posted)
      @check_number = check
      @check        = Claim.where(check_number: check)
      @posted       = posted
    end

    def pdf_report
      if check.count == 0
        puts "No claims were found with this check number. Please re-enter."
        self.run_report
      else
        create_pdf
      end
    end

    def provider
      Provider[check.get(:provider_id)].name
    end

    def create_pdf
      puts "creating report for #{provider} - Check Number: #{check.get(:check_number)} - posted on: #{posted}"
      report.collate_services
    end

    def report
      CheckEOP.new(check, posted, provider, check_number)
    end
  end

  class CheckEOP < Reporter
    attr_reader :posted, :check_number, :claims, :pdf

    def initialize(claims, posted, provider, check_number)
      @claims       = claims
      @posted       = posted
      @provider     = provider
      @check_number = check_number
      @pdf          = Prawn::Document.generate("#{LOCAL_FILES}/#{provider}-#{check_number}.PDF")
    end

    def collate_services
      
    end
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
end