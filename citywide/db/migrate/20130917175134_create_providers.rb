class CreateProviders < ActiveRecord::Migration
  def change
    create_table :providers do |t|
      t.string :name
      t.integer :fund
      t.integer :account
      t.integer :d_account

      t.timestamps
    end
  end
end
