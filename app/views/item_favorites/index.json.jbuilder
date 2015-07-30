json.array!(@item_favorites) do |item_favorite|
  json.extract! item_favorite, :id, :item_id, :user_id, :create_user_id, :update_user_id
  json.url item_favorite_url(item_favorite, format: :json)
end
