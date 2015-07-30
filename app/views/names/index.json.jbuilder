json.array!(@names) do |name|
  json.extract! name, :id, :name_kbn, :name_id, :name, :create_user_id, :update_user_id
  json.url name_url(name, format: :json)
end
