require 'prawn'
require 'csv'
require 'sequel'
require_relative 'fund_ez_ar_aging_hash_guildnet.rb'
DB = Sequel.connect('sqlite://project.db')


# DB.create_table(:services) do
#   primary_key :id
#   String      :service_date
#   Float       :open_amt
#   Float       :billed_amt
#   String      :patient_id
#   Integer     :service_id
#   String      :patient_name
# end

# DB.create_table :authorizations do
#   primary_key :id
#   foreign_key :service_id, :services
#   Integer     :service_num
#   String      :auth_number
# end



module Parser
  DB = Sequel.connect('sqlite://project.db')
  def self.parse_file(file)
    PDF::Reader.new('./archive/special/' + file).pages.each do |page|
      # if page.raw_content.include?('GUILDNET')
      #   page.raw_content.scan(/^\(.{27}(\d+)\s+\d+\s+\S+\s+\S\s+([A-Z0-9\-\/]+)\s+\d\s+(\S+)\s+(\S+)(?=\)')/) do |line|
      #     start_date = Time.new("20#{line[2][6..7]}", line[2][0..1].to_i, line[2][3..4].to_i)
      #     end_date   = Time.new("20#{line[3][6..7]}", line[3][0..1].to_i, line[3][3..4].to_i)
      #     Authorization.insert(auth_number: line[1], service_num: line[0].to_i, start_date: start_date, end_date: end_date)
      #   end
      puts page.raw_content
      page.raw_content.scan(/^\(([0-9\/]{8}).{20}\s+([0-9\,.]+)\s+([0-9\.,]+)?.{11}(\d+)?\s(\S+)?\s+(\d+)?\s(.{15})/) do |line| # 
        print "#{line}\n"
        service_date = Time.new("20#{line[0][6..7]}", line[0][0..1].to_i, line[0][3..4].to_i)
        Service.insert(service_date: service_date, open_amt: line[1].to_f, billed_amt: line[2].to_f, patient_id: line[4], service_id: line[5].to_i, patient_name: line[6], invoice_number: line[3].to_i)
      end
    end
  end

  def self.compare_dbs
    AR_AGING.each do |invoice, data|
      inv = Invoice.new(invoice, data[:balance], data[:client])
      inv.get_services
    end
  end

  def self.match_with_fund_ez
    AR_SHP.each do |invoice, data|
      print "#{invoice} #{data}\n" if Service.where(invoice_number: invoice.to_i).first.nil? 
      Service.where(invoice_number: invoice.to_i).all.each do |svc|
        CSV.open('report-shp-sdas.csv', 'a+') do |row|
          row << [svc.invoice_number, svc.patient_name, svc.service_date, svc.billed_amt, svc.open_amt, svc.auth_number, svc.start_date, svc.end_date, data[:balance], svc.patient_id]  
        end
      end
    end
  end
  class Invoice
    def initialize(invoice, balance, client)
      @invoice, @balance, @client = invoice, balance, client
    end

    def get_services
      Service.where(invoice_number: @invoice.to_i).all.each {|svc| get_auths(svc)}
    end

    def get_auths(svc)
      Authorization.where(service_num: svc.service_id).all.each{|auth| compare_dates(auth, svc.service_date, svc.id)}
    end

    def compare_dates(auths, service_date, id)
      if service_date >= auths.start_date && service_date <= auths.end_date
        Service.where(service_date: service_date, id: id).update(auth_number: auths.auth_number, end_date: auths.end_date.strftime('%m/%d/%Y'), start_date: auths.start_date.strftime('%m/%d/%Y'))
        print "#{auths.start_date.strftime('%m/%d/%Y')} #{auths.end_date.strftime('%m/%d/%Y')} #{service_date}\n"
      end
    end
  end
  class Service < Sequel::Model; end
  class Authorization < Sequel::Model; end
end

# Parser.match_with_fund_ez
# Parser.get_service_ids
# Parser.compare_dbs
Parser.parse_file('open_date.PDF')
# Parser.match_val {|val| Service.where(service_id: val.service_num).update(auth_num: val.auth_num, end_date: val.end_date, start_date: val.start_date)}
parse = /\(.{28}(\d+)\s+\d+\s+\S+\s+\S\s+([0-9\-\/]+)\s+\d\s+(\S+)\s+(\S+)(?=\)')/ # service_num, client_num, auth, auth_start, auth_end