class Log
  include MongoMapper::Document
  key :fromUser, String
  key :content, String
  key :type, String
  key :time, Time
  key :MediaId, String
  key :CreateTime, String
  key :event, String
end
