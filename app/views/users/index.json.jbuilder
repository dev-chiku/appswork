json.array!(@users) do |user|
  json.extract! user, :id, :unique_id, :display_name, :content, :img_path, :create_user_id, :update_user_id
  json.url user_url(user, format: :json)
end
