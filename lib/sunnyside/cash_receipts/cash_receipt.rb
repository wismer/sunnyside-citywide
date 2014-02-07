module Sunnyside

  def self.cash_receipt
    puts "1.) EDI PAYMENT"
    puts "2.) MANUAL PAYMENT"
    puts "3.) RESET A/R SPREADSHEET"
    case gets.chomp
    when '1'
      cash_receipt = CashReceipt.new(:electronic)
    when '2'
      cash_receipt = CashReceipt.new(:manual)
    when '3'
      CSV.open("#{DRIVE}/sunnyside-files/cash_receipts/EDI-citywide-import.csv", "w") { |row| 
        row << ['Seq','Receipt','post_date','other id','invoice','header memo','batch','doc date','detail memo','fund','account','cc1','cc2','cc3','debit','credit']
      }
    end
    cash_receipt.collate if cash_receipt
  end

  class CashReceipt
    attr_reader :post_date, :type_of_entry

    def initialize(type_of_entry)
      print "Enter in post date (YYYY-MM-DD): "
      @post_date        = Date.parse(gets.chomp)
      @type_of_entry    = type_of_entry
    end

    def collate
      case type_of_entry
      when :electronic
        Sunnyside.check_prompt { |payment_id| EdiPayment.new(payment_id, post_date).collate }
      when :manual
        manual_invoices
      else
        exit
      end
    end

    def invoice_selection
      puts "Enter in the invoices, each separated by a space. If any invoice has a denial, 'flag' it by typing '-d' after the invoice number.\n"
      invoices = gets.chomp.split
      print "You have typed out #{invoices.length} number of invoices. Do you wish to add more to the same check? (Y or N): "
      if gets.chomp.upcase == 'Y'
        more_invoices = gets.chomp.split
        return (more_invoices + invoices).uniq
      else
        return invoices.uniq
      end
    end

    def manual_invoices
      print "# of checks to enter for the post date of #{post_date}? "
      num = gets.chomp.to_i
      num.times do 
        prov     = provider
        print "Enter in the check number: "
        check    = gets.chomp
        invoices = invoice_selection
        if invoices_exist?(invoices)
          manual   = ManualPayment.new(invoices, post_date, prov, check) 
          manual.seed_claims_and_services
          manual.create_csv
        else
          manual_invoices
        end
      end
    end

    def invoices_exist?(invoices)
      invoices.map { |invoice| invoice.gsub(/-d/, '') }.all? { |invoice| !Invoice[invoice].nil? }
    end

    def provider
      Provider.all.each { |prov| puts "#{prov.id}: #{prov.name}"}
      print "Type in the Provider ID: "
      return Provider[gets.chomp] || ''
    end
  end



  class EdiPayment
    include Sunnyside
    attr_reader :payment, :post_date

    def initialize(payment, post_date)
      @payment, @post_date = payment, post_date
    end

    def populated_data
      Claim.where(payment_id: payment.id).all.select { |clm| clm.paid > 0.0 }
    end

    def total
      populated_data.map { |clm| clm.paid }.inject { |x, y| x + y }.round(2)
    end

    def collate
      puts "Total Amount Paid for this check is: #{total}\nProcessing..."
      populated_data.each do |clm| 
        if !not_fully_paid?(clm)
          self.receivable_csv(clm, payment, post_date)  
        else
          print "#{clm.invoice_id} was not added to the spreadsheet because the invoice was already fully paid for.\n"
          print "Please consider this $#{clm.paid} as an interest payment.\n"
        end
      end
      puts "----------------------------------------------------------------------------------------------------------"
      puts "------------------------------Check added to #{DRIVE}/EDI-citywide-import.csv-----------------------------"
      puts "-------------Please note that there are #{denied_services} service days with possible denials-------------"
      puts "----------------------------------------------------------------------------------------------------------"
    end



    def not_fully_paid?(clm)
      Claim.where(invoice_id: clm.invoice_id).sum(:paid).round(2) < clm.paid
    end

    def denied_services
      Service.where(payment_id: payment.id).exclude(denial_reason: nil).count
    end
  end

  class ManualPayment
    include Sunnyside
    attr_reader :denied_invoices, :paid_invoices, :post_date, :provider, :check, :payment_id, :total

    def initialize(invoices, post_date, prov, check)
      @denied_invoices = invoices.select { |inv| inv.include?('-d') }.map { |inv| Invoice[inv.gsub(/-d/, '')] }
      @paid_invoices   = invoices.reject { |inv| inv.include?('-d') }.map { |inv| Invoice[inv] }
      @post_date       = post_date
      @provider        = prov
      @check           = check
      @payment_id      = Payment.insert(check_number: check, post_date: post_date, provider_id: prov.id)
      @total           = 0.0
    end

    def seed_claims_and_services
      (denied_invoices + paid_invoices).each do |invoice|
        claim_id = create_claim(invoice)
        create_services(invoice, claim_id)
      end
      edit_services if denied_invoices.length > 0
    end

    def not_fully_paid?(clm)
      Claim.where(invoice_id: clm.invoice_id).sum(:paid).round(2) < Invoice[clm.invoice_id].amount
    end

    def create_csv
      claims.each { |clm| 
        if clm.paid > 0.0 
          self.receivable_csv(clm, Payment[payment_id], post_date) 
        end
      }
      Payment[payment_id].update(check_total: check_total)
    end

    def claims
      (denied_invoices + paid_invoices).map { |inv| Claim.where(invoice_id: inv.invoice_number, payment_id: payment_id).first }
    end

    def create_claim(invoice)
      paid =  if invoice.provider_id == 22  # for the stupid rate that village care max pays
                (invoice.amount * 0.999365).round(2)
              else
                invoice.amount
              end

      Claim.insert(
        :invoice_id   => invoice.invoice_number, 
        :client_id    => invoice.client_id, 
        :billed       => invoice.amount, 
        :paid         => paid, 
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

    def edit_services
      denied_invoices.each { |inv| 
        services     = Service.where(invoice_id: inv.invoice_number, payment_id: payment_id)
        edit_service = EditService.new(services) 
        edit_service.show_all

        edit_service.adjust
        
        adjust_claim(inv)
      }
    end

    def visits(invoice)
      Visit.where(invoice_id: invoice.invoice_number).all
    end

    def adjust_claim(inv)
      service_sum = Service.where(payment_id: payment_id, invoice_id: inv.invoice_number).sum(:paid).round(2)
      Claim.where(invoice_id: inv.invoice_number, payment_id: payment_id).update(:paid => service_sum)
    end

    def check_total
      Claim.where(payment_id: payment_id).sum(:paid).round(2)
    end
  end

  class EditService
    attr_reader :services

    def initialize(services)
      @services = services.all
    end

    def show_all
      services.each { |svc| puts "ID: #{svc.id} #{svc.dos} #{svc.service_code} #{svc.paid}" }
    end

    def adjust
      print "Type in the Service(s) ID # to change the amount: "
      ids     = gets.chomp.split
      ids.each do |id|
        print "You selected #{id} - Type in the adjusted amount: "
        amt    = gets.chomp
        print "And now type in the denial reason: "
        reason = gets.chomp
        adjust_service(id, amt, reason)
      end
    end

    def adjust_service(id, amt, reason)
      Service[id].update(paid: amt, denial_reason: reason)
    end
  end
end