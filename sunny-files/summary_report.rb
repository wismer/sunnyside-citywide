module Sunnyside
  def self.billed_services(post_date)
    Billed.new(post_date).create_report
  end

  class Billed
    attr_reader :providers, :invoices, :post_date
    def initialize(post_date)
      @post_date = post_date
      @invoices  = Invoice.where(post_date: post_date)
      @providers = Invoice.where(post_date: post_date).map(:provider).uniq
    end

    def create_report
      providers.each { |provider| CSV.open("#{post_date}-summary.csv", "a+") { |row| row << [provider, hours_by(provider).round(2)] } }
    end

    def hours_by(provider)
      invoices.where(provider: provider).sum(:hours)
    end
  end
end