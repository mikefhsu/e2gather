json.array!(@events) do |event|
  json.extract! event, :event_id, :name, :location, :date_time, :host, :ingredient_list, :guest_list, :status
  json.url event_url(event, format: :json)
end
