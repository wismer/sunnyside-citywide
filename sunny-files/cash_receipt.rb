module Sunnyside
  class CashReceipt
    def initialize
      loop do 
        print "Manual entry or EDI? "
        @entry_method = gets.chomp
        if @entry_method.downcase == 'edi'
          print "Enter provider: "
          provider = gets.chomp
          print "enter post_date: "
          @post_date = gets.chomp
          if !provider.empty?
            show_all_checks(provider)
          else
            show_check_by_amt
          end
          check_info
          gather_data
        elsif @entry_method.downcase == 'manual'
          print "Enter post_date: "
          @post_date = gets.chomp
          print "number of checks? "
          check_count = gets.to_i
          manual_msg
          check_count.times do 
            check_info
            manual_entry
          end
        else 
          break
        end
      end
    end
    
    def show_check_by_amt
      Payment.where(check_total: gets.chomp).all.each {|chk| puts "#{chk.check_number} #{chk.check_total}"}
    end

    def show_all_checks(provider)
      Claim.where(Sequel.ilike(:provider, "#{provider}%")).map(:check_number).uniq.each {|clm| puts "#{clm} #{check_amt(clm)}" if !check_amt(clm).nil?}
    end

    def check_amt(check)
      Payment.where(check_number: check).get(:check_total)
    end

    def check_info
      print "Enter Check #: "
      @check = gets.chomp
      @total = 0.0
    end

    def manual_msg
      print "***********************************************************************NOTE********************************************************************************************\n"
      print "* If there is an invoice with a denial, type in the invoice number as normal but affix a '-d' at the end of the invoice number. (e.g. 256862 256863 256864-d 254485)  *\n"
      print "***********************************************************************NOTE********************************************************************************************\n"
    end

    def manual_entry
      print "\n          Enter invoices, each separated by a space.\n"
      invoices = gets.chomp.split(' ').uniq
      invoices.each { |invoice| 
        if invoice.include?('-d')
          adjust_for_denial(invoice)
        else
          set_variables(invoice)
        end
      }
    end

    def gather_data
      claims.map(:invoice_number).uniq.each { |invoice| set_variables(invoice) }
    end

    def adjust_for_denial(invoice)
      invoice = invoice.gsub(/\-d/, '')
      print "You've selected #{invoice} as having a denial. Please type in the adjusted total: "
      amt = gets.chomp.to_f
      set_variables(invoice, amt)
    end

    def set_variables(invoice, amt = nil)
      amount    = amt || ( claim(invoice).sum(:amount_paid) || find_invoice(invoice).get(:amount) )
      prov_name = find_invoice(invoice).get(:provider)
      provider  = provider_data(prov_name)
      client    = find_invoice(invoice).get(:client_name)
      client_id = get_client(client).get(:fund_id)
      create_csv(invoice, provider, client_id, amount) if amount > 0.0
    end

    def provider_data(name)
      Provider.where(name: name).first
    end

    def get_client(client)
      Client.where(client_name: client)
    end

    def find_invoice(inv)
      Invoice.where(invoice_number: inv)
    end

    def claim(inv)
      claims.where(invoice_number: inv)
    end

    def claims
      Claim.where(check_number: @check)      
    end

    def cl(id)
      Client.where(fund_id: id).get(:client_name)
    end
    
    def create_csv(invoice, prov, client, amount)
      puts "#{invoice} #{amount} #{(@total += amount).round(2)} #{cl(client)} #{prov.name}"
      CSV.open("./ledger-files/EDI-citywide-import.csv", "a+") do |row| # #{post_date.gsub(/\//, '-')}-
        row << [1, @check, 
                  @post_date, 
                  client, 
                  invoice, 
                  invoice, 
                  "#{@post_date[0..1]}/13#{prov.abbrev}", 
                  @post_date, 
                  invoice, 
                  prov.fund, prov.credit_acct,'','','', 0,  amount.round(2)]
        row << [2, @check, 
                  @post_date, 
                  client, 
                  invoice, 
                  invoice, 
                  "#{@post_date[0..1]}/13#{prov.abbrev}", 
                  @post_date, 
                  invoice, 
                  100,         1000,'','','', amount.round(2),    0]
        row << [3, @check, 
                  @post_date, 
                  client, 
                  invoice, 
                  invoice, 
                  "#{@post_date[0..1]}/13#{prov.abbrev}", 
                  @post_date, 
                  invoice, 
                  prov.fund,         3990, '', '', '', amount.round(2), 0]
        row << [4, @check, 
                  @post_date, 
                  client, 
                  invoice, 
                  invoice, 
                  "#{@post_date[0..1]}/13#{prov.abbrev}", 
                  @post_date, 
                  invoice, 
                  100,         3990, '', '', '', 0, amount.round(2)]
      end       
    end
  end

  # class PaymentRecord < CashReceipt
  #   attr_accessor :client_name, :invoice, :sum_total
  #   def initialize(invoice, check, @post_date)
  #     @invoice, @check, @post_date = invoice, check, post_date
  #     @client_name                 = inv.client_name
  #     @sum_total ||= 0.0
  #   end

  #   def find_claim
  #     Claim.where(invoice_number: @invoice, check_number: @check)
  #   end

  #   def find_prov
  #     Provider.where(name: inv.provider).first
  #   end

  #   def inv
  #     Invoice.where(invoice_number: @invoice).first
  #   end

  #   def client
  #     Client.where(client_name: inv.client_name).first
  #   end

  #   def balance
  #     Claim.where(invoice_number: @invoice).exclude(check_number: @check).sum(:amount_paid) || 0.0
  #   end

  #   def take_back

  #   end

  #   def not_paid?
  #     balance < inv.amount # looks for all payments outside of the check and gets the sum. if less than the invoice amount, then applies to csv.
  #   end

  #   def create_csv # Begum has an invoice thats for 405 bucks. It was paid in full in 2 payments. I want to ignore what was already paid.
  #     super(@check, @post_date, inv, find_prov, client, take_back)
  #   end
  # end
end


