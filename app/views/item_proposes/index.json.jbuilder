json.array!(@item_proposes) do |item_propose|
  json.extract! item_propose, :id, :item_id, :payment_kbn, :price, :noki, :hour_price_kbn, :week_hour_kbn, :week_hour_period_kbn, :content, :create_user_id, :update_user_id
  json.url item_propose_url(item_propose, format: :json)
end
