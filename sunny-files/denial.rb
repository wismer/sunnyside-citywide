module Sunnyside

  def self.process_denial_by_client_name
    client = Client.where(med_id: gets.chomp)
    DenialClient.new(client).process if client.count > 0
  end

  def self.process_denial_by_check_number
    Denial.new(gets.chomp).process
  end

  class DenialClient
    attr_reader :client, :name

    def initialize(client)
      @client   = client
      @name     = client.get(:client_name)
    end

    def invoices
      Invoice.where(client_name: name).map(:invoice_number)
    end

    def check
      services_with_denials.map { |svc| svc.check_number }
    end

    def services
      Service.where(invoice_number: invoices).all
    end

    def process
      services_with_denials.each { |svc| ProcessDenial.new(svc, check).commit } 
    end

    def services_with_denials
      services.select { |svc| svc.amount_paid < svc.amount_charged && svc.amount_paid >= 0 }
    end
  end

  class Denial
    attr_reader :svcs, :check

    def initialize(check)
      @check = check
      if Claim.where(check_number: check).count > 0
        @svcs = Service.where(check_number: check).all
      else
        @svcs = nil #Claim.where(Sequel.ilike(:provider, "#{check}%")).map { |ck| Service.where(claim_id: ck.id).all }
      end
    end

    def services_with_denials
      svcs.select { |svc| svc.amount_paid < svc.amount_charged && svc.amount_paid >= 0 }
    end

    def process
      if svcs.nil?
        show_checks
      else
        services_with_denials.each { |svc| ProcessDenial.new(svc, check).commit } 
      end
    end

    def by_check
      Claim.where(Sequel.ilike(:provider, "#{check}%")).map(:check_number).uniq
    end

    def show_checks
      by_check.each { |chk| puts "#{check} #{chk} #{check_total(chk)}" }
      puts 'Type in check number: '
      @check = gets.chomp
      @svcs = Service.where(check_number: check).all
      process
    end

    def check_total(chk)
      Service.where(check_number: chk).sum(:amount_paid).round(2)
    end
  end
  class ProcessDenial
    attr_reader :svc, :claim_id, :control_number, :recipient_id, :invoice, :check

    def initialize(svc, check)
      @check          = check
      @svc            = svc
      @claim_id       = svc.claim_id
      @invoice        = Invoice.where(invoice_number: svc .invoice_number)
      @control_number = Claim.where(id: svc.claim_id).get(:control_number)
      @recipient_id   = Invoice.where(invoice_number: svc.invoice_number).get(:recipient_id)
    end


    def commit
      puts "#{svc.check_number}, #{svc.invoice_number}, #{invoice.get(:client_name)}, #{svc.dos}, #{svc.service_code}, #{svc.amount_charged}, #{svc.amount_paid}, #{svc.denial_reason}, #{ctrl}, #{auth_number}, #{recipient_id}"
      CSV.open("denial-eops/#{title}-denials", 'a+') { |row| row << [svc.check_number, svc.invoice_number, invoice.get(:client_name), svc.dos, svc.service_code, svc.amount_charged, svc.amount_paid, svc.denial_reason, ctrl, auth_number, recipient_id] }
    end

    def title
      invoice.get(:provider)
    end

    def ctrl
      if invoice.get(:provider) == 'GUILDNET'
        date_control.strftime('%m/%d/%Y') + '-' + control_number[8..10] + '-' + control_number[11..12] 
      else
        control_number
      end
    end

    def auth_number
      invoice.get(:auth)
    end

    def date_control
      Date.strptime(control_number[0..7], '%m%d%Y')
    end
  end
end