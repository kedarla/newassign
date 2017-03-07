class CreateBills < ActiveRecord::Migration
  def change
    create_table :bills do |t|
      t.integer :total
      t.integer :amar_paid
      t.integer :akbar_paid
      t.integer :anthony_paid

      t.timestamps null: false
    end
  end
end
