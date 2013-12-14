module Sunnyside

  def check
    puts 'Type of Payment? (EDI or MANUAL)'
    return gets.chomp.upcase == 'EDI' ? :edi : :manual
  end

  def manual_prompt
    print 'Enter in the # of checks you wish to enter: '
    checks = gets.chomp
  end

  def edi_prompt
    print 'Enter in the Check Number and the Post Date now by typing in this format: <check_number> <post_date> (ex. 235466 10/12/2013): '
    check_number, post_date = gets.chomp.split(' ')
    EdiPayment.new(check_number, post_date).to_csv
  end

  class CashReceipt
    include Sunnyside
    attr_reader :type
    def initialize
      @type = self.check
    end

    def process
      if type == :edi
        self.edi_prompt
      elsif type == :manual
        self.manual_prompt
      else
        exit
      end
    end
  end

  class EdiPayment
    include Sunnyside
    attr_reader :claims, :post_date, :check_number

    def initialize(check_number, post_date)
      @claims       = Claim.where(check_number: check_number)
      @post_date    = post_date
      @check_number = check_number
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

  class InvoiceLine
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