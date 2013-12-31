module Sunnyside

  def self.cash_receipt
    puts "1.) EDI PAYMENT"
    puts "2.) MANUAL PAYMENT"
    payment = 
      case gets.chomp
      when '1'
        EdiPayment.new
      when '2'
        ManualPayment.new
      end
    payment.collate
  end

  def check_date_abbre
    puts 'Enter in check number, post date and then followed by the provider abbreviation (separated by a space - ex: 235345 10/12/2013 WEL): '
    ans = gets.chomp.split
    if ans.size == 3
      return ans
    else
      raise 'You need to enter in the specified fields.'
    end
  end

  def invoice_numbers
    puts 'Enter in invoices, each separated by a space. If an invoice contains any denials, flag it by typing in a "-d" right after the last number. '
    return gets.chomp.split
  end

  class EdiPayment
    include Sunnyside
    attr_reader :check_number, :post_date, :prov

    def initialize
      @check_number, @post_date, @prov = self.check_date_abbre
    end

    def invoices
      Claim.where(check_number: check_number).map { |clm| clm.invoice_id }.uniq
    end

    def populated_data
      invoices.map { |inv| Invoice[inv] }
    end

    def total
      populated_data.map { |inv| inv.amount }.inject { |x, y| x + y }.round(2)
    end

    def payment_id
      Payment.where(check_number: check_number).get(:id)
    end

    def collate
      puts "Total Amount Paid for this check is: #{total}\nProcessing..."
      populated_data.each { |inv| self.receivable_csv(inv, payment_id, check_number, post_date) if inv.amount > 0.0 }
      puts "Check added to #{LOCAL_FILES}/EDI-citywide-import.csv"
      puts "Please note that there are #{denied_services} service days with possible denials"
    end

    def denied_services
      Service.where(check_number: check_number).exclude(denial_reason: [nil, '']).count
    end
  end

  class ManualPayment < CashReceipt
    attr_reader :check, :manual_invs, :post_date, :prov

    def initialize
      @check, @post_date, @prov = self.check_date_abbre
      @manual_invs              = self.invoice_numbers
    end

    def provider
      Provider.where(abbreviation: prov).first
    end

    def payment_id
      if check_exists?
        Payment.where(check_number: check, post_date: post_date, provider_id: provider.id).get(:id)
      else
        Payment.insert(check_number: check, post_date: post_date, provider_id: provider.id)
      end
    end

    def check_exists?
      Payment.where(check_number: check, post_date: post_date, provider_id: provider.id).count > 0
    end

    def date
      Date.strptime(post_date, '%m/%d/%Y')
    end

    def collate
      manual_invs.each { |inv| 
        # manual invoice number is matched with what is in the DB
        invoice  ||= Invoice[inv.gsub(/-d/, '')]
        # claim is then created and saved to the DB; the ID for the particular claim created is saved as claim_id
        claim_id = create_claim(invoice)
        # service entries are created by duplicating the visits that were originally charged
        create_services(invoice, claim_id)
        # if a -d is present in ( inv ), the invoice is then marked as denied (or the payment amount doesnt match the billed)
        # services that have foreign_key = claim_id, are then shown the user, which are then edited.
        edit_services(claim_id) if denial_present?(inv)
        # after that, the payments are then finalized and posted to the csv file creator for importing into FUND EZ
        self.receivable_csv(invoice, payment_id, check, post_date)
      }
    end

    def invoice_data(inv)
      invoice = inv.gsub(/-d/, '').to_i
      yield Invoice[invoice]
    end

    def create_claim(invoice)
      Claim.insert(
        :invoice_id   => invoice.id, 
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

    def edit_services(inv)
      service = EditServices.new(inv, payment_id)
      loop do 
        service.show_all
        service.adjust
      end
    end

    def denial_present?(invoice)
      invoice.include?('-d')
    end

    def visits(invoice)
      Visit.where(invoice_id: invoice.invoice_number).all
    end

    class EditServices < ManualPayment::CashReceipt
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