json.array!(@user_work_categories) do |user_work_category|
  json.extract! user_work_category, :id, :user_id, :name_id
  json.url user_work_category_url(user_work_category, format: :json)
end
