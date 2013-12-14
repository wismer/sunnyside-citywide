require 'sequel' # 4 5 and 8 # client memo amt
require 'csv'
require 'date'
DB = Sequel.connect('sqlite://../project.db') 

module Sunnyside
  class Report
    attr_reader :client_numbers
    
    def initialize
      @client_numbers = CSV.open('../new_data/data.csv', 'r').map { |e| e[1] }
    end

    def process
      client_numbers.each { |client| ClientReport.new(client).details }
    end
  end

  class ClientReport
    attr_reader :member_id, :invoices, :client, :visit
    NURSING = ['T1001', 'T1030', 'T1031', 'S9123', 'S9124', 'G0162']
    def initialize(member_id)
      @member_id  = member_id
      @invoices   = Invoice.where(service_number: member_id).map(:invoice_number)
      @client     = Client.where(med_id: member_id).get(:client_name)
      @visit      = Visit.where(member_id: member_id, dos: Date.new(2011,8,1)..Date.new(2012,6,30)).exclude(service_code: NURSING)
    end

    def details
      if visit?
        CSV.open('results.csv', 'a+') { |row| row << [client, member_id, total_amount, total_hours] }
      else
        CSV.open('results.csv', 'a+') { |row| row << [client, member_id, 0.0, 0.0] }
      end
    end

    def visit?
      visit.count > 0
    end

    def total_amount
      visit.sum(:amount).round(2)
    end

    def total_hours
      total = 0.0

      visit.all.each { |vis| 
        Rate.new(vis).determine_rate do |rate|
          total += rate
        end
        puts total
      }
      return total
      # visit.map(:service_code).uniq.each { |code| Rate.new(code, visit) }
    end
  end

  class Rate
    attr_reader :visit, :hours, :code, :live_in

    def initialize(visit)
      @code    = visit.service_code
      @visit   = visit
      @hours   = []
      @live_in = ['T1021', 'T1020', 'T1022', 'S5126', 'S1019']
    end

    def determine_rate
      # first determines whether the service code is a live-in code or a regular PCA/HHA code
      if live_in.include?(code)
        yield live_in_rate
      else
        yield pca_hra_rate
      end
    end

    def pca_hra_rate
      # if hourly, returns true if the amount/units result is greater than $12 but less than $50
      if hourly?
        units
      else
        units / 4.0
      end
    end

    def live_in_rate
      if hourly?
        units
      elsif unit_rate > 50.0 && units <= 1.0
        units * 12.0
      else
        units / 4.0
      end
    end

    def hourly?
      unit_rate > 12.0 && unit_rate < 50.0
    end

    def unit_rate
      amount / units
    end

    def units
      visit.units
    end

    def amount
      visit.amount
    end
  end
  class Visit < Sequel::Model; end
  class Invoice < Sequel::Model; end
  class Filelib < Sequel::Model; end
  class Payment < Sequel::Model; end
  class Claim < Sequel::Model; end
  class Client < Sequel::Model; end
  class Service < Sequel::Model; end
  class Provider < Sequel::Model; end
end

Sunnyside::Report.new.process

