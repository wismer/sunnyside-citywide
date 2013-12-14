require 'sequel'
require 'date'
DB = Sequel.connect('sqlite://sunnyside-test.db')

DB.drop_table :services
DB.drop_table :claims
DB.drop_table :payments
DB.drop_table :invoices
DB.drop_table :filelibs
# DB.drop_table :charges
DB.drop_table :providers
DB.drop_table :clients
DB.drop_table :visits
DB.drop_table :authorizations

# DB.create_table :charges do 
#   primary_key   :id
#   foreign_key   :invoice_id, :invoices
#   foreign_key   :provider_id, :providers
#   Date          :dos
#   Float         :amount
#   Float         :units
#   String        :service_code
#   String        :filename
# end

DB.create_table :invoices do 
  Integer       :invoice_number, :primary_key=>true
  index         :invoice_number
  Float         :amount
  Date          :post_date, :default=>Date.today
  foreign_key   :client_id, :clients
  foreign_key   :provider_id, :providers
  foreign_key   :filelib_id, :filelibs
  String        :client_name
  Float         :rate
  Float         :hours
  String        :recipient_id
  String        :authorization
end

DB.create_table :payments do 
  primary_key   :id 
  foreign_key   :provider_id, :providers
  foreign_key   :filelib_id, :filelibs
  Float         :check_total
  String        :status
  Integer       :check_number
end

DB.create_table :claims do 
  primary_key   :id
  index         :id
  String        :control_number
  foreign_key   :payment_id, :payments
  foreign_key   :invoice_id, :invoices
  foreign_key   :client_id, :clients
  Integer       :check_number
  Float         :paid 
  Float         :billed
  String        :status
  String        :recipient_id
  foreign_key   :provider_id, :providers
  Date          :post_date
end

DB.create_table :services do 
  primary_key   :id
  foreign_key   :claim_id, :claims
  foreign_key   :payment_id, :payments
  foreign_key   :invoice_id, :invoices
  foreign_key   :client_id, :clients
  String        :service_code
  Float         :paid
  Float         :billed
  String        :denial_reason
  Float         :units
  Date          :dos
end

DB.create_table :clients do
  Integer       :client_number, :primary_key=>true
  String        :client_name
  String        :fund_id
  String        :recipient_id
end

DB.create_table :providers do 
  primary_key   :id
  Integer       :credit_account
  Integer       :fund 
  Integer       :debit_account
  String        :name
  String        :abbreviation
  String        :type
end

DB.create_table :filelibs do
  primary_key   :id
  String        :filename
  String        :purpose
  String        :file_type
  Time          :created_at
end

DB.create_table :visits do 
  primary_key :id
  String      :service_code
  String      :modifier
  foreign_key :invoice_id, :invoices
  foreign_key :client_id, :clients
  Float       :amount
  Float       :units
  Date        :dos
end

DB.create_table :authorizations do 
  String      :auth, :primary_key=>true
  foreign_key :client_id, :clients
  Integer     :service_id
  Date        :start_date
  Date        :end_date
end

DBO = Sequel.connect('sqlite://project.db')
DBO[:providers].all.each do |prov|
  DB[:providers].insert(credit_account: prov[:credit_acct], name: prov[:name], abbreviation: prov[:abbrev], debit_account: prov[:debit_acct], fund: prov[:fund], type: prov[:type])
end