require 'sequel'

DB = Sequel.connect('sqlite://../project.db')

# DB.create_table :invoices do 
#   Integer     :invoice_number, :primary_key=>true
#   String      :client_name
#   Float       :amount
#   foreign_key :client_id, :clients
#   String      :provider
#   String      :authorization
# end

# DB.create_table :services do
#   primary_key :id
#   String      :service_code
#   String      :modifier
#   Date        :dos
#   Float       :units
#   Float       :amount
#   foreign_key :invoice_id, :invoices
#   foreign_key :client_id, :clients
# end

# DB.create_table :clients do
#   Integer     :client_number, :primary_key=>true
#   String      :client_name
#   String      :recipient_id
# end
