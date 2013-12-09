class Ingredient < ActiveRecord::Base
self.primary_key='id'
belongs_to :user
validates_presence_of :name
validates_presence_of :unit
validates :quantity, numericality: { less_than_or_equal_to: 10000, greater_than: 0}
end
