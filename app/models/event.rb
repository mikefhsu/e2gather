class Event < ActiveRecord::Base
  self.primary_key='event_id'
  belongs_to :user, foreign_key: "host_id"
  has_many :ingredients
end
