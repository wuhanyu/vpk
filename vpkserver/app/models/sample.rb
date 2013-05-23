class Sample
  include MongoMapper::Document

  key :content, String
  key :type, Integer

end
