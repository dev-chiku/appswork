json.array!(@notifications) do |notification|
  json.extract! notification, :id, :notification_kbn, :target_id, :user_id, :create_user_id, :update_user_id
  json.url notification_url(notification, format: :json)
end
