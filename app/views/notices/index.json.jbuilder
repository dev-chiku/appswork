json.array!(@notices) do |notice|
  json.extract! notice, :id, :title, :content, :create_user_id, :update_user_id
  json.url notice_url(notice, format: :json)
end
