module Sunnyside
  def self.erratic
    Errata.new.process
  end
  class Errata
    attr_reader :invoices

    def initialize
      @invoices = Invoice.map { |inv| inv.invoice_number if (inv.rate * inv.hours).round(2) != inv.amount }
    end

    def process
      invoices.each { |invoice| VisitRate.new(invoice).examine if Visit.where(invoice_number: invoice).count > 0 }
    end
  end

  class VisitRate
    attr_reader :visits, :live_in_codes

    def initialize(invoice)
      @visits        = Visit.where(invoice_number: invoice)
      @live_in_codes = ['T1020', 'T1001', 'T1030', 'T1031', 'S9123', 'S9124', 'G0162', 'T1021', 'T1022', 'S5126', 'S1019']
    end

    def multiple_services
    
    end


    def live_in?
      services.any? { |svc| live_in_codes.include?(svc) }
    end

    def single_service
      if live_in?
        'gasdasd '
      else
        calculate_rates
      end
    end

    def calculate_rates
      visits.all.each { |visit| 
        
      }
    end

    def examine
      if services.size > 1
        multiple_services
      else
        single_service
      end
    end

    def services
      visits.map(:service_code)
    end

    def method_name
      
    end
  end
end