class CreateInvoices < ActiveRecord::Migration
  def change
    create_table :invoices do |t|
      t.integer :inv_number
      t.float :amount
      t.date :post_date

      t.timestamps
    end
  end
end
