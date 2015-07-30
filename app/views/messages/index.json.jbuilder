json.array!(@messages) do |message|
  json.extract! message, :id, :message_kbn, :parent_id, :user_id, :title, :content, :create_user_id, :update_user_id
  json.url message_url(message, format: :json)
end
