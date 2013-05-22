class User
  include MongoMapper::Document
  key :openid, String
  key :uid, String
  key :created_at, Time
  key :last_active_at, Time
  key :user_status, String
  key :rate_at, String
  key :rate_count, Integer
end
