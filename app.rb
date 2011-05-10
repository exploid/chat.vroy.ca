require "rubygems"

gem "ramaze", "2009.03"
require "ramaze"

require "json"

require "juggernaut"

Ramaze.acquire("controller/*")

require "sequel"
DB = Sequel.connect("mysql://root:asdf@localhost/chat")

Ramaze.acquire("model/*")


require "github/markup"
