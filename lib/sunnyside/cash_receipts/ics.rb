# Not implemented yet

module Sunnyside
  def self.ics_file
    Dir['data/icseop/*.csv'].each { |file| ICS.new(file).process }
  end

  class ICS
    attr_reader :rows

    def initialize(file)
      p "processing #{file}..."
      @rows = CSV.read(file)
    end

    def checks
      rows.map { |row| row[0] }.uniq
    end

    def invoices(check)
      rows.select { |row| row[0] == check }.map { |row| row[1] }.uniq.map { |inv| Invoice[inv] }
    end

    def paid(inv, check)
      rows.select { |row| row[1].to_i == inv.get(:invoice_number) && row[0] == check }.map { |i| i[3].to_f }.inject { |x, y| x + y}.round(2)
    end

    def seed_claims
      checks.each do |check|
        payment_id = Payment.insert(check_number: check)
        invoices(check).each { |invoice| 
          Claim.insert(
            :payment_id     => payment_id, 
            :invoice_id     => invoice, 
            :client_name    => invoice.get(:client_name), 
            :amount_charged => invoice.get(:amount), 
            :amount_paid    => paid(invoice, check), 
            :provider       => invoice.get(:provider) ) 
        }
      end
    end

    def process
      seed_claims
      rows.each { |row| ICSEop.new(row).write }
    end
  end

  class ICSEop < ICS
    attr_reader :check, :invoice, :charged, :paid, :dos, :service_code, :provider

    def initialize(row)
      @check, @invoice, @charged, @paid, @dos, @service_code = row
      @provider = Provider[13]
    end

    def write
      Service.insert(claim_id: claim_id, service_code: service_code, amount_charged: charged, amount_paid: paid, dos: date, check_number: check)
    end

    def date
      Date.strptime(dos, '%m/%d/%Y')
    end

    def claim_id
      Claim.where(invoice_number: invoice, check_number: check).get(:id)
    end
  end
end