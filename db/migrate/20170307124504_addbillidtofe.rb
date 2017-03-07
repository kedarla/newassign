class Addbillidtofe < ActiveRecord::Migration
  def change
  	add_column :bills,:food_event_id,:integer
  end
end
