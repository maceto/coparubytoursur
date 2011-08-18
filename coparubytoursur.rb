require "cuba"
require "haml"

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
        puts player['name']
        res.redirect "/"
      end
    end
  end

end
