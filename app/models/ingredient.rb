class Ingredient < ActiveRecord::Base
  self.primary_key='ingredient_id'
  belongs_to :user
end
