class Event < ActiveRecord::Base
  self.primary_key='event_id'
  belongs_to :user
  has_many :ingredients
end
