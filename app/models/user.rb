class User < ActiveRecord::Base
  self.primary_key='user_id'
  has_many :ingredients, dependent: :destroy
  has_many :events, dependent: :destroy
end
