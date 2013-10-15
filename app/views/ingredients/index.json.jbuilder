json.array!(@ingredients) do |ingredient|
  json.extract! ingredient, :ingredient_id, :name, :quantity, :unit, :user_id, :brought
  json.url ingredient_url(ingredient, format: :json)
end
