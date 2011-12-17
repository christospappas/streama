$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

MODELS = File.join(File.dirname(__FILE__), "app/models")
SUPPORT = File.join(File.dirname(__FILE__), "support")
$LOAD_PATH.unshift(MODELS)
$LOAD_PATH.unshift(SUPPORT)

require 'streama'
require 'mongoid'
require 'rspec'

LOGGER = Logger.new($stdout)
DATABASE_ID = Process.pid

Mongoid.configure do |config|
  database = Mongo::Connection.new.db("mongoid_#{DATABASE_ID}")
  database.add_user("mongoid", "test")
  config.master = database
  config.logger = nil
end

Dir[ File.join(MODELS, "*.rb") ].sort.each do |file|
  name = File.basename(file, ".rb")
  autoload name.camelize.to_sym, name
end

Dir[ File.join(SUPPORT, "*.rb") ].each do |file|
  require File.basename(file)
end

RSpec.configure do |config|
  config.include RSpec::Matchers
  config.include Mongoid::Matchers
  config.mock_with :rspec
  
  config.before(:each) do
    Mongoid::IdentityMap.clear
  end
  
  config.after :suite do
    Mongoid.master.connection.drop_database("mongoid_#{DATABASE_ID}")
  end
  
end
