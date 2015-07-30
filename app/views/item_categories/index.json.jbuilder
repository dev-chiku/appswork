json.array!(@item_categories) do |item_category|
  json.extract! item_category, :id, :item_id, :category_id, :create_user_id, :update_user_id
  json.url item_category_url(item_category, format: :json)
end
