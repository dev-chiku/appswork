json.array!(@item_goods) do |item_good|
  json.extract! item_good, :id, :item_id, :user_id, :create_user_id, :update_user_id
  json.url item_good_url(item_good, format: :json)
end
