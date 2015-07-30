json.array!(@items) do |item|
  json.extract! item, :id, :payment_kbn, :price, :noki, :week_hour, :period_kbn, :option_kbn, :limit_date, :title, :content, :img_path, :create_user_id, :update_user_id
  json.url item_url(item, format: :json)
end
