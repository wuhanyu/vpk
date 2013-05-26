class Rec
  include MongoMapper::Document
  key :deleted, Boolean
  key :win_count, Integer
end
