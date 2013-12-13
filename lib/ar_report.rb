module Sunnyside
  class Report
    def initialize
      @data = []
      Claim.where(payment_id: gets.chomp).all.each do |inv|
        @data << [inv.invoice_id, inv.control_number, inv.paid]
      end
      create_pdf
    end

    def create_pdf
      # provider = inv.join(:providers, :provider_id=>:id)
      Prawn::Document.generate('sampsle.pdf') do |pdf|
        puts pdf.class
        { :borders => [:top, :left] }
        create_header(pdf)
        create_table(pdf)
        pdf.text "Invoice   Claim Number     Amount"

        # pdf.text "#{i.invoice_id} #{i.control_number} #{i.paid}"
      end
    end

    def create_header(pdf)
      pdf.text "asdasd"
    end

    def create_table(pdf)
      pdf.bounding_box([100, 200], :width => 100) do 
        pdf.table([['FUCK', 'THIS', 'SHIT']] * 2, :cell_style => { :borders => [:left, :right] })       
      end
    end
  end
end

