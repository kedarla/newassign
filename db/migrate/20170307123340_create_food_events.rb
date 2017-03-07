class CreateFoodEvents < ActiveRecord::Migration
  def change
    create_table :food_events do |t|
      t.string :name
      t.boolean :amar_present
      t.boolean :akbar_present
      t.boolean :anthony_present

      t.timestamps null: false
    end
  end
end
