json.array!(@roles) do |role|
  json.extract! role, :id, :user_id, :role_name
  json.url role_url(role, format: :json)
end
