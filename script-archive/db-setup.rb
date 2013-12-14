require 'sequel'

DB.create_table :clients do
  String       :fund, :primary_key=>true
  String       :client_name
end

DB.create_table :invoices do
  Integer      :invoice_number, :primary_key=>true
  foreign_key  :client_id, :clients
  foreign_key  :provider_id, :providers
  Date         :post_date
end

DB.create_table :payments do
  Integer       :check_number, :primary_key=>true
end

DB.create_table :claims do
  Integer       :control_number, :primary_key=>true
  foreign_key   :payment_id, :payments
  Float         :charged
  Float         :paid
  String        :status
  String        :client_name
  foreign_key   :invoice_id, :invoices
end

DB.create_table :filelib do
end

DB.create_table :services do
  primary_key :id
  foreign_key :claim_id, :claims
  foreign_key :payment_id, :payments
  String      :service_code
  Date        :dos
  Float       :units
  Float       :charged
  Float       :paid
  String      :denial_code
end

DB.create_table :providers do 
  String       :provider_name, :primary_key=>true
  Integer      :fund
  Integer      :credit_acct
  Integer      :debit_acct
end