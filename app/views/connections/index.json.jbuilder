json.array!(@connections) do |connection|
  json.extract! connection, :id, :connect_kbn, :from_user_id, :to_user_id, :target_id, :create_user_id, :update_user_id
  json.url connection_url(connection, format: :json)
end
