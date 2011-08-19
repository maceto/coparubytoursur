require "cuba"
require "haml"
require "datamapper"
require "dm-sqlite-adapter"

DataMapper.setup(:default, 'sqlite://db/development.db')
DataMapper::Logger.new($stdout, :debug)

class Player 
  include DataMapper::Resource

  property :id, Serial
  property :name, String, :required => true
  property :mail, String, :required => true
  property :twitter, String, :required => true
  property :country, String, :required => true

end
DataMapper.finalize
DataMapper.auto_upgrade!

Cuba.use Rack::Static, urls: [ "/public/styles", "/public/images" ]

Cuba.define do

  # only GET requests
  on get do
    # /
    on "" do
      @players = Player.all(:order => [ :name.desc ])
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
