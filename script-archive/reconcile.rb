require 'csv'
require 'sequel'

DB = Sequel.connect('sqlite://citywide-db.db')

post_dates = DB[:invoices].map(:post_date).uniq
providers  = DB[:providers].map(:name)

post_dates.each do |pd|
  providers.each do |prov|
    sum = DB[:invoices].where(post_date: pd, provider: prov).sum(:invoice_amount)
    CSV.open('reconcile.csv', 'a+') {|row| row << [pd, prov, sum]}
  end
end