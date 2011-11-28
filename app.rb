require "rubygems"

# Third party libraries
gem "ramaze", "2011.10.23"
require "ramaze"

require "json"
require "juggernaut"
require "github/markup"
require "albino"

# Application setup
Ramaze.acquire("controller/*")

require "mongoid"
Mongoid.configure do |config|
  config.master = Mongo::Connection.new.db("chat_vroy_ca")
end

Ramaze.acquire("model/*")
