require 'csv'
require 'sequel'

DB = Sequel.connect('sqlite://sunnyside.db')

CSV.foreach('client_list.csv') do |row|
  DB[:clients].where(client_number: row[2]).update(client_name: row[0], fund_id: row[1])
end