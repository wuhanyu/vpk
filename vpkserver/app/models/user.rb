class User
  include MongoMapper::Document
  key :openid, String
  key :fakeid, Integer
  key :uid, String
  key :created_at, Time
  key :last_active_at, Time
  key :avatar_url, String
  key :nickname, String
  key :user_status, String

end
