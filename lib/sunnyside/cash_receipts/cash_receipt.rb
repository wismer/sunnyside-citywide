module Sunnyside

  def payment_type
    puts "1.) EDI PAYMENT"
    puts "2.) MANUAL PAYMENT"
    return gets.chomp.upcase == '1' ? EdiPayment.new : ManualPayment.new
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

  class CashReceipt
    include Sunnyside
    attr_reader :type
    def initialize
      @type = self.payment_type
    end

    def process
      type.collate
    end
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

    def payment_id
      if check_exists?
        Payment.where(check_number: check, post_date: post_date).get(:id)
      else
        Payment.insert(check_number: check, post_date: post_date)
      end
    end

    def check_exists?
      Payment.where(check_number: check, post_date: post_date).count > 0
    end

    def date
      Date.strptime(post_date, '%m/%d/%Y')
    end

    def map_claims_and_services
      manual_invs.each { |inv| 
        invoice         = Invoice[invoice.gsub(/-d/, '')]
        claim_id        = create_claim(invoice)
        create_services(invoice, claim_id)
      }
    end

    def collate
      map_claims_and_services
      manual_invs.each { |inv|
        if denial_present?(inv)
          edit_services(inv)
        else
          self.receivable_csv(invoice, payment_id, check, post_date)
        }
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
          :units        => visit.units 
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
      invoice = inv.gsub(/-d/, '').to_i
      print "Select the day you wish to edit by the corresponding number followed by the adjusted amount\n"
      print "When you are finished, type 'done'."
      print "(e.g. 3451 23.50) Enter in the number now: "
      loop do 
        services(invoice).all.each { |svc| puts "#{svc.id} #{svc.dos} #{svc.service_code} #{svc.modifier} #{svc.paid}" }
        id, adjusted_amt = gets.chomp.split
        if !id.nil?
          print "Type in the denial reason now: "
          denial_reason = gets.chomp
          Service[id].update(paid: adjusted_amt, denial_reason: denial_reason)
        else 
          break
        end
      end
    end

    def denial_present?(invoice)
      invoice.include?('-d')
    end

    def visits(invoice)
      Visit.where(invoice_id: invoice.invoice_number).all
    end
  end
end