module Sunnyside

  def payment_type
    puts 'Type of Payment? (EDI or MANUAL)'
    return gets.chomp.upcase == 'EDI' ? EdiPayment.new : ManualPayment.new
  end

  def check_number_and_date
    puts 'Enter in check number followed by the post date (separated by a space - ex: 235345 10/12/2013): '
    return gets.chomp.split(' ')
  end

  def invoice_numbers
    puts 'Enter in invoices, each separated by a space. If an invoice contains any denials, flag it by typing in a "-d" right after the last number. '
    return gets.chomp.split(' ')
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
    attr_reader :claims, :post_date, :check_number

    def initialize
      @check_number, @post_date = self.check_number_and_date
    end

    def invoices
      claims.map { |clm| clm.invoice_number }.uniq
    end

    def populated_data
      invoices.map { |inv| InvoiceLine.new(inv, post_date, check_number) }
    end

    def total
      populated_data.map { |inv| inv.amount }.inject { |x, y| x + y }.round(2)
    end

    def to_csv
      puts "Total Amount Paid for this check is: #{total}\nProcessing..."
      populated_data.each { |inv| self.create_csv(inv) if inv.amount > 0.0 }
      puts "Check added to ledger-files/EDI-citywide-import.csv"
      puts "Please note that there are #{denied_services} service days with possible denials"
    end

    def denied_services
      Service.where(check_number: check_number).exclude(denial_reason: [nil, '']).count
    end
  end

  class ManualPayment < CashReceipt
    attr_reader :check, :invoices, :post_date

    def initialize
      @check, @post_date = self.check_number_and_date
      @invoices          = self.invoice_numbers
    end

    def payment_id
      if check_exists?
        Payment.where(check_number: check).get(:id)
      else
        Payment.insert(check_number: check)
      end
    end

    def check_exists?
      Payment.where(check_number: check).count > 0
    end

    def date
      Date.strptime(post_date, '%m/%d/%Y')
    end

    def collate
      invoices.each { |inv|
        invoice_data(inv) { |invoice| 
          claim_id = create_claim(invoice)
          create_services(invoice, claim_id)
          edit_services(inv) if denial_present?(inv)
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
        :invoice_id   => invoice.invoice_number, 
        :client_id    => invoice.client_id, 
        :billed       => invoice.amount, 
        :paid         => 0.0, 
        :payment_id   => payment_id, 
        :check_number => check, 
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