class Event < ActiveRecord::Base
  self.primary_key='id'
  belongs_to :user, foreign_key: "host"
  has_many :ingredients
  validates_presence_of :name
end
