class User
  include MongoMapper::Document
  key :openid, String
  key :uid, String
  key :created_at, Time
  key :last_active_at, Time
  key :user_status, String
  key :rate_at, String
  key :rate_count, Integer
  key :avatar_url, String
  key :name, String
  key :sex, Integer
  key :meng, Array
  key :menged_count, Integer
  key :rank, Integer
  key :overall_rating, Integer
  key :rec_count, Integer
end
