module Sunnyside
  def self.run_mco_mltc
    print "Type in post date (YYYY-MM-DD): "
    post_date = gets.chomp
    Provider.map(:name).each do |provider|
      ReportMCO.new(provider, post_date).run
    end
  end

  class ReportMCO
    attr_reader :provider, :post_date, :clients
    # attr_accessor :mco_total, :mltc_total

    def initialize(provider, post_date)
      @provider   = provider
      @post_date  = post_date 
      @clients    = Client.where(provider: provider)
      # @mco_total  = 0.0
      # @mltc_total = 0.0
    end

    def run
      mco_total  = 0.0
      mltc_total = 0.0
      invoices.each do |inv|
        if inv[:type] == 'MCO'
          mco_total += inv[:hours]
        elsif inv[:type] == 'MLTC'  
          mltc_total += inv[:hours]
        end
      end
      puts "#{provider}: MCO => #{mco_total} MLTC => #{mltc_total}"
    end

    def invoices
      Invoice.where(provider: provider, post_date: post_date).all.map { |invoice| 
        { :type  => Client.where(med_id: invoice.service_number).exclude(type: nil).get(:type),
          :hours => invoice.hours }
      }
    end
  end
end