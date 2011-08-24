require "cuba"
require "haml"
require "datamapper"
require "dm-sqlite-adapter"

#DataMapper.setup(:default, 'sqlite://db/development.db')
DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/db/development.db")
DataMapper::Logger.new($stdout, :debug)

class Player 
  include DataMapper::Resource

  property :id, Serial
  property :name, String, :required => true, :messages => { :presence  => 'Nombre es obligatorio.'}
  property :mail, String, :required => true, :messages => { :presence  => 'eMail es obligatorio.'}
  property :twitter, String, :required => true, :messages => { :presence  => 'Twitter es obligatorio.'}
  property :country, String, :required => true, :messages => { :presence  => 'Pais es obligatorio.'}

end
DataMapper.finalize
DataMapper.auto_upgrade!

Cuba.use Rack::Static, urls: [ "/public/styles", "/public/images" ]
Cuba.use Rack::Session::Cookie

Cuba.define do

  def session
   @session ||= env['rack.session']
  end

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
    message = ""
    session["message"]= message
    on "players" do
      on param("player") do |player_attributes|
        player = Player.new(player_attributes)
        if player.save
          message = "La inscripcion se realizo con exito !!!"
        else
          player.errors.each do |e|
            message += e.join + " ,"
          end
        end
        session["message"]= message
        res.redirect "/"
      end
    end
  end

end
