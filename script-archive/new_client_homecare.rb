require 'sequel'

DB = Sequel.connect('sqlite://homecare.db')

loop do
  print "Add the Client Name exactly how it appears in the error list: "
  name = gets.chomp
  print "Now type in the client ID as it appears in FUND EZ: "
  fund_id = gets.chomp
  DB[:clients].insert(name: name, fund_id: fund_id.to_i)
  puts DB[:clients].where(name: name, fund_id: fund_id.to_i).all
end