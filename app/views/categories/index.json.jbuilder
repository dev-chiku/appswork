json.array!(@categories) do |category|
  json.extract! category, :id, :name, :create_user_id, :update_user_id
  json.url category_url(category, format: :json)
end
