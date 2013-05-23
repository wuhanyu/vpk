class Newmatch
  include MongoMapper::Document
  key :category, String
  key :uid_a, String
  key :uid_b, String
  key :result, Integer
  key :rater, String
  key :created_at, Time
  key :rid_a, String
  key :rid_b, String
  key :mid, String
end
