json.array!(@users) do |user|
  json.extract! user, :user_id, :user_name, :user_email
  json.url user_url(user, format: :json)
end
