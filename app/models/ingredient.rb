class Ingredient < ActiveRecord::Base
self.primary_key='ingredient_id'
belongs_to :user
validates_presence_of :name
validates_presence_of :unit
validates_numericality_of :quantity, :message=>"Error Message"
end
