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
    attr_reader :check_number, :invoices, :post_date

    def initialize
      @check, @post_date = self.check_number_and_date
      @invoices          = self.invoice_numbers
    end

    def payment_id
      if check_exists?
        Payment.where(check_number: check_number).get(:id)
      else
        Payment.insert(check_number: check_number)
      end
    end

    def check_exists?
      Payment.where(check_number: check_number).count > 0
    end

    def date
      Date.strptime(post_date, '%m/%d/%Y')
    end

    def collate
      invoices.each { |inv|
        add_services(inv) { |svcs| svcs.create_claim }
        if denial_present?(inv)
          edit_services(inv)
        else
          self.payable_csv(inv)
        end
      }
    end

    def services(invoice)
      Service.where(payment_id: payment_id, invoice_id: invoice)
    end

    def edit_services(invoice)
      print "Select the day you wish to edit by the corresponding number followed by the adjusted amount\n"
      print "When you are finished, press enter."
      print "(e.g. 3451 23.50) Enter in the number now: "
      loop do 
        services.all.each { |svc| puts "#{svc.id} #{svc.dos} #{svc.service_code} #{svc.modifier} #{svc.paid}" }
        day, adjusted_amt = gets.chomp.split
        if !day.empty?
          Service[day].update(paid: adjusted_amt)
        else
          edit_services(invoice)
        end
      end

    end

    def add_services(invoice)
      yield AddService.new(invoice)
    end

    def denial_present?(invoice)
      invoice.include?('-d')
    end

    def visits(invoice)
      Visit.where(invoice_id: invoice).all
    end
  end

  class AddService < CashReceipt
    attr_reader :visits, :claim_id

    def initialize(invoice, claim_id)
      @visits     = Visit.where(invoice_id: invoice)
      @claim_id   = claim_id
      @payment_id = payment_id  
    end

    def visits_exist?
      visits.count > 0
    end

    def process_visits
      visits.all.each do |visit|
        Service.insert(
          :payment_id   => payment_id, 
          :invoice_id   => visit.invoice_id, 
          :claim_id     => claim_id, 
          :service_code => visit.service_code, 
          :billed       => visit.amount, 
          :dos          => visit.dos
        )
      end
    end

    def new_services
      if visits_exist?
        process_visits
      else
        puts 'No visits found for this invoice number.'
      end
    end
  end

  class InvoiceLine < EdiPayment
    attr_reader :invoice_number, :post_date, :check_number

    def initialize(invoice_number, post_date, check_number)
      @invoice_number = invoice_number
      @post_date      = post_date
      @check_number   = check_number
    end

    def amount
      Service.where(invoice_number: invoice_number, check_number: check_number).sum(:amount_paid).round(2)
    end

    def provider_name
      Invoice.where(invoice_number: invoice_number).get(:provider)
    end

    def client
      Invoice.where(invoice_number: invoice_number).get(:client_name)
    end

    def client_id
      Client.where(client_name: client).get(:fund_id)
    end

    def provider
      Provider.where(name: provider_name).first
    end
  end
end