require 'sequel'

DB = Sequel.connect('sqlite://proj.db')

DB.create_table :clients do
  String :fund_id, :primary_key=>true
  String :name
  index :fund_id
end

DB.create_table :invoices do
  Integer :invoice_number, :primary_key=>true