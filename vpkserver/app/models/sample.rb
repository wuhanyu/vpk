class Sample
  include MongoMapper::Document

  key :content, String
  key :type, Integer
  key :created_at, Time
end
