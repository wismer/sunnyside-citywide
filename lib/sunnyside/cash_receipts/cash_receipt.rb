module Sunnyside

  def self.cash_receipt
    puts "1.) EDI PAYMENT"
    puts "2.) MANUAL PAYMENT"
    cash_receipt = 
      case gets.chomp
      when '1'
        CashReceipt.new(:electronic)
      when '2'
        CashReceipt.new(:manual)
      end
    cash_receipt.collate
  end

  # def check_date_abbre
  #   puts 'Enter in check number, post date and then followed by the provider abbreviation (separated by a space - ex: 235345 10/12/2013 WEL): '
  #   ans = gets.chomp.split
  #   if ans.size == 3
  #     return ans
  #   else
  #     raise 'You need to enter in the specified fields.'
  #   end
  # end

  # def invoice_numbers
  #   puts 'Enter in invoices, each separated by a space. If an invoice contains any denials, flag it by typing in a "-d" right after the last number. '
  #   return gets.chomp.split
  # end



  class CashReceipt
    attr_reader :post_date
    def initialize(method)
      print "Enter in post date (YYYY-MM-DD): "
      @post_date = Date.parse(gets.chomp)
      @method    = method
    end

    def collate
      case method
      when :electronic
        edi_provider_and_check
      when :manual
        manual_invoices
      else
        break
      end
    end

    def edi_provider_and_check
      provider = Provider[gets.chomp]
      Payment.where(provider_id: provider.id).all.each { |check| "#{check.id}: Number - #{check.check_number} Amount - #{check.check_total}"}
      print "Type in the Check ID: "
      payment = Payment[gets.chomp]
      check   = EdiPayment.new(payment, post_date, provider) 
      check.collate
    end

    def provider
      Provider.all.each { |prov| "#{prov.id}: #{prov.name}"}
      print "Type in the Provider ID: "
      if !Provider[gets.chomp].nil?
        return Provider[gets.chomp]
      else
        provider
      end
    end

    def manual_invoices
      print "# of checks to enter for the post date of #{post_date}? "
      num = gets.chomp.to_i
      num.times do 
        prov = provider
        print "Enter in the check number: "
        check = gets.chomp
        puts "Enter in the invoices, each separated by a space. If any invoice has a denial, 'flag' it by typing '-d' after the invoice number.\n"
        invoices    = gets.chomp.split
        manual = ManualPayment.new(invoices, post_date, prov, check)
        manual.seed_claims_and_services
        manual.create_csv
      end
    end
  end

  class EdiPayment
    include Sunnyside
    attr_reader :payment, :post_date, :provider

    def initialize(payment, post_date, provider)
      @payment, @post_date, @provider = payment.check_number, post_date, provider
    end

    def invoices
      Claim.where(payment_id: payment.id).map { |clm| clm.invoice_id }.uniq
    end

    def populated_data
      invoices.map { |inv| Invoice[inv] }
    end

    def total
      populated_data.map { |inv| inv.amount }.inject { |x, y| x + y }.round(2)
    end

    def payment_id
      payment.id
    end

    def collate
      puts "Total Amount Paid for this check is: #{total}\nProcessing..."
      populated_data.each { |inv| self.receivable_csv(inv, payment_id, payment, post_date) if inv.amount > 0.0 }
      puts "Check added to #{LOCAL_FILES}/EDI-citywide-import.csv"
      puts "Please note that there are #{denied_services} service days with possible denials"
    end

    def denied_services
      Service.where(check_number: check_number).exclude(denial_reason: nil).count
    end
  end

  class ManualPayment
    attr_reader :denied_invoices, :paid_invoices, :post_date, :provider, :check

    def initialize(invoices, post_date, prov, check)
      @denied_invoices = invoices.select { |inv| inv.include?('-d') }.map { |inv| Invoice[inv.gsub(/-d/, '')] }
      @paid_invoices   = invoices.reject { |inv| inv.include?('-d') }.map { |inv| Invoice[inv] }
      @post_date       = post_date
      @provider        = prov
      @check           = check
      @payment_id      = Payment.insert(check_number: check, post_date: post_date, provider_id: provider.id)
    end

    def seed_claims_and_services
      (denied_invoices + paid_invoices).each do |invoice|
        claim_id = create_claim(invoice)
        create_services(invoice, claim_id)
      end
      edit_services if denied_invoices.length > 0
    end

    def create_csv
      (denied_invoices + paid_invoices).each { |inv| self.receivable_csv(inv, payment_id, check, post_date) }
    end

    def create_claim(invoice)
      Claim.insert(
        :invoice_id   => invoice.invoice_number, 
        :client_id    => invoice.client_id, 
        :billed       => invoice.amount, 
        :paid         => 0.0, 
        :payment_id   => payment_id, 
        :provider_id  => invoice.provider_id
      )
    end

    def create_services(invoice, claim_id)
      visits(invoice).each { |visit| 
        Service.insert(
          :invoice_id   => visit.invoice_id, 
          :payment_id   => payment_id, 
          :claim_id     => claim_id, 
          :service_code => visit.service_code, 
          :paid         => visit.amount, 
          :billed       => visit.amount, 
          :dos          => visit.dos,
          :units        => visit.units,
          :client_id    => Claim[claim_id].client_id
        )
      }
    end

    def visits(invoice)
      Visit.where(invoice_id: invoice.invoice_number).all
    end

    def services(inv)
      Service.where(payment_id: payment_id, invoice_id: inv)
    end

    def edit_services
      denied_services.each { |inv| 
        service = EditServices.new(inv, payment_id)
        loop do 
          service.show_all
          service.adjust
        end
      }
    end

    def visits(invoice)
      Visit.where(invoice_id: invoice.invoice_number).all
    end

    class EditServices
      attr_reader :claim

      def initialize(claim_id)
        @claim    = Claim[claim_id]
        @services = Service.where(claim_id: claim_id).all
      end

      def show_all
        services.each { |svc| puts "ID: #{svc.id} #{svc.dos} #{svc.amount}" }
      end

      def adjust
        print "Type in the Service ID # to change the amount: "
        id     = gets.chomp
        print "You selected #{id} - Type in the adjusted amount: "
        amt    = gets.chomp
        print "And now type in the denial reason: "
        reason = gets.chomp
        adjust_service(id, amt, reason)
      end

      def adjust_service
        Service[id].update(paid: amt, denial_reason: reason)
      end
    end
  end
end