class Event < ActiveRecord::Base
  self.primary_key='event_id'
  belongs_to :user, foreign_key: "host"
  has_many :ingredients
end
