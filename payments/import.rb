require 'sequel'
require 'csv'
require 'pp'
require_relative 'import.rb'
DB = Sequel.connect('sqlite://../project.db')

# DB[:filelibs].map(:filename).reject{|x| x !~ /\.csv/}.each {|x| DB[:filelibs].where(filename: x).delete}
# DB[:claims].where()
@payments = []
class Service < Sequel::Model; end
class Claim < Sequel::Model; end

Dir.entries('.').reject{|x| x !~ /.csv/}.each do |file|
  # puts DB[:filelibs].where(filename: file).all
  # unless DB[:filelibs].where(filename: file).get(:filename) == file
    print "Processing #{file}...\n" 

    CSV.foreach(file) {|csv|
      @payments << csv
      # if DB[:invoices].where(invoice_number: csv[4]).get(:invoice_number)
      #   provider = DB[:invoices].where(invoice_number: csv[4]).get(:provider)
      #   client   = DB[:clients].where(fund_id: csv[5]).get(:client_name)
      #   print "#{client} #{provider} #{csv[2]}\n" if provider
      #   Claim.insert(invoice_number: csv[4], amount_paid: csv[2].gsub(/,/,''), provider: provider, check_number: csv[1], client_name: client, ref_file: file)
      #   Service.insert(claim_id: Claim.last.id, amount_paid: csv[2].gsub(/,/,''), check_number: csv[1])
      # end
    }
    @payments.map!{|pay|
      pay = {
        check_number: pay[1],
        client_id:    pay[5],
        invoice_id:   pay[4],
        amount:       pay[2],
        post_date:    pay[0]
      } 
    }
    pp @payments
  # DB[:filelibs].insert(filename: file, purpose: 'csv')
end
