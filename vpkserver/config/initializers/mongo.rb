MongoMapper.connection = Mongo::Connection.new('124.16.139.143', 27017)
MongoMapper.database = "vpk-#{Rails.env}"

if defined?(PhusionPassenger)
  PhusionPassenger.on_event(:starting_worker_process) do |forked|
    MongoMapper.connection.connect if forked
  end
end