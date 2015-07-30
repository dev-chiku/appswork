json.array!(@item_comments) do |item_comment|
  json.extract! item_comment, :id, :item_id, :user_id, :nicname, :comment, :password, :create_user_id, :update_user_id
  json.url item_comment_url(item_comment, format: :json)
end
