class User < ActiveRecord::Base
self.primary_key='user_id'
has_many :ingredients, dependent: :destroy
has_many :events, dependent: :destroy

def ==(other_object)
	self.user_id == other_object.user_id
end

end
