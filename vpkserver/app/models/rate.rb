class Rate
  include MongoMapper::Document
  key :wincount_a, Integer
  key :wincount_b, Integer
end
