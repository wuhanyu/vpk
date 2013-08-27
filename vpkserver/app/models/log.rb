class Log
  include MongoMapper::Document
  key :fromUser, String
  key :content, String
  key :type, String
  key :time, Time
  key :MediaId, String
  key :CreateTime, String
  key :event, String
  
  def self.grouped_by(column, options = {})
    map_function = "function() { emit( this.#{column}, 1); }"
    
    # put your logic here (not needed in my case)
    reduce_function = %Q( function(key, values) { 
      return true;
    })
    
    collection.map_reduce(map_function, reduce_function, options)
  end
end
