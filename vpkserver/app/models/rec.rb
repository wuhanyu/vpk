class Rec
  include MongoMapper::Document
  key :deleted, Boolean
  key :win_count, Integer
  key :play_count, Integer
  key :MediaId, String
end
