class CreateClients < ActiveRecord::Migration
  def change
    create_table :clients do |t|
      t.string :name
      t.string :fund_id

      t.timestamps
    end
  end
end
