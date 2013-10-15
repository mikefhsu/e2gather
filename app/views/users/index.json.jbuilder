json.array!(@users) do |user|
  json.extract! user, :user_id, :name, :email, :refrigerator_list, :event_list
  json.url user_url(user, format: :json)
end
