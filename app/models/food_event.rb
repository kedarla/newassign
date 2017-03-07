class FoodEvent < ActiveRecord::Base
	has_one :bill
end
