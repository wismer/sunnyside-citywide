require 'sequel'

DB = Sequel.connect('sqlite://citywide-db.db')

invoice_list = DB[:invoices].map(:invoice_number) # all invoices
puts invoice_list.length 
invoice_list.uniq!
puts invoice_list.length
invoice_list.each do |inv|
  arr = DB[:invoices].where(invoice_number: inv).all
  if arr.length > 1
    arr.delete(0)
    arr.map! {|x| x[:id]}.each {|id| DB[:invoices].where(:id => id).delete}
  end
  # arr.each {|pop| DB[:invoices].where(invoice_number: pop).delete}
end

puts invoice_list.length
