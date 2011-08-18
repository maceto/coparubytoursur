require "cuba"
require "haml"
require "datamapper"
require "dm-sqlite-adapter"

DataMapper.setup(:default, 'sqlite://db/development.db')
DataMapper::Logger.new($stdout, :debug)

class Player 
  include DataMapper::Resource

  property :id, Serial
  property :name, String
  property :mail, String
  property :twitter, String

end
DataMapper.finalize
DataMapper.auto_upgrade!

Cuba.use Rack::Static, urls: [ "/public/styles", "/public/images" ]

Cuba.define do

  # only GET requests
  on get do
    # /
    on "" do
      puts "fue get"
      res.write render('views/index.haml')
    end
  end

  # only POST requests
  on post do
    on "players" do
      on param("player") do |player_attributes|
        Player.create(player_attributes)
        res.redirect "/"
      end
    end
  end

end
