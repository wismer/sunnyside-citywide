require 'sequel' # 4 5 and 8 # client memo amt
require 'csv'
require 'date'

DB = Sequel.connect('sqlite://../projects-test.db')
module Sunnyside
  class Chart
    attr_reader   :payments, :checks
    def initialize
      @payments = Claim.where(status: 'special import')
      @checks   = []
    end

    def sort_checks
      payments.map(:payment_id).uniq.each do |payment|
        total = 0.0
        provider = Claim.where(payment_id: payment, status: 'special import').get(:provider_id)
        puts "#{Claim.where(payment_id: payment, status: 'special import').sum(:paid).round(2)} #{Provider[provider].name} #{Payment[payment].check_number}"
        Claim.where(status: 'special import', payment_id: payment).all.each do |pay|
          claims = CheckData.new(pay.payment_id, pay.post_date, pay.invoice_id, pay.paid, pay.provider_id)
          claims.claim_info { |amt| total += amt }
        end
        CSV.open('totals.csv', 'a+') {|row| row << [Payment[payment].check_number, Provider[provider].name, total.round(2), clm(payment).get(:post_date)]}
      end
    end

    def clm(pm)
      Claim.where(payment_id: pm, status: 'special import')
    end

    def prov
      Provider
    end

    def chk(pm)
      Claim.where(payment_id: pm, status: 'special import').get(:provider_id)
    end
  end

  class CheckData < Chart
    attr_reader :receipt, :post, :inv, :paid, :provider, :fiscal_year
    def initialize(receipt, post, inv, paid, provider)
      @receipt, @post, @inv, @paid, @provider = receipt, post, inv, paid, provider
      @fiscal_year = Date.new(2012,7,1)..Date.new(2013,6,30)
    end

    def claim_info
      if charge.count > 0
        yield amt if charges_paid? && within_date_range?
      end
    end

    def amt
      charge.where(dos: fiscal_year).sum(:amount).round(2)
    end

    def within_date_range?
      charge.map(:dos).any? { |day| fiscal_year?(day) }
    end

    def fiscal_year?(day)
      day <= Date.new(2013,6,30) && day >= Date.new(2012,7,1)
    end

    def charges_paid?
      charge.sum(:amount) >= paid
    end

    def charge
      Charge.where(invoice_id: inv)
    end
  end
  class FindInvoice
    attr_reader :client, :client_id, :invoice, :amount, :post_date, :receipt, :fiscal_year
    def initialize(row)
      @client, @client_id, @invoice, @amount, @post_date, @receipt = row
    end

    def insert_to_db
      puts "#{invoice} #{amount} #{receipt} #{prov_name}"
      if invoice.to_i > 199538
        Payment.insert(check_number: receipt) unless Payment.map(:check_number).include?(receipt)
        Claim.insert(payment_id: check, paid: amount.gsub(/,/, ''), invoice_id: invoice, status: 'special import', provider_id: prov_name, post_date: Date.strptime(post_date, '%m/%d/%Y'))
      end
    end

    def check
      Payment.where(check_number: receipt).get(:id)
    end

    def prov_name
      Invoice.where(invoice_number: invoice).get(:provider_id)
    end

    def find_by_invoice
      mark_as_paid if charges_paid? && within_date_range?
    end

    def within_date_range?
      charge.map(:dos).any? { |day| fiscal_year?(day) }
    end

    def mark_as_paid
      puts "#{inv} in full"
    end

    def fiscal_year?(day)
      day <= Date.new(2013,6,30) && day >= Date.new(2012,7,1)
    end

    def charges_paid?
      charge.sum(:amount) >= amount.gsub(/,/, '').to_f
    end

    def charge
      Charge.where(invoice_id: invoice)
    end

    def claim
      Claim.where(invoice_id: invoice, status: 'special import', check_number: receipt)
    end
  end

  class Invoice < Sequel::Model; end
  class Filelib < Sequel::Model; end
  class Payment < Sequel::Model; end
  class Claim < Sequel::Model; end
  class Client < Sequel::Model; end
  class Service < Sequel::Model; end
  class Provider < Sequel::Model; end
  class Charge < Sequel::Model; end
end
chart = Sunnyside::Chart.new
chart.sort_checks
# Dir["../data/*.csv"].each do |file| 
#   CSV.foreach(file) do |row|
#     inv = Sunnyside::FindInvoice.new(row)
#     inv.insert_to_db
#   end
# end

# Client.all.each do |client|
#   service_numbers = []
#   Invoice.where(client_name: client.client_name).all.each do |inv|
#     service_numbers << inv.service_number
#   end
#   puts "#{client.client_name} has #{service_numbers.uniq.size} service numbers" if service_numbers.uniq.size > 1
# end
# sub = 0.0
# Claim.where(check_number: ARGV[0]).map(:invoice_number).uniq.sort.each do |clm|
#   amt    = Claim.where(check_number: ARGV[0], invoice_number: clm).sum(:amount_paid).round(2)
#   client = Invoice.where(invoice_number: clm).get(:client_name)
#   puts "#{clm} #{amt} #{(sub+=amt).round(2)} #{client}"
# end
