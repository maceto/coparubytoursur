require "cuba"
require "haml"
require "net/http"
require "net/https"
require "json"
require "datamapper"
require "dm-sqlite-adapter"
require 'yaml'

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

  def authenticate_eventioz(email, password, email_attendant)
    # get the api_key
    uri = URI.parse("https://eventioz.com/session.json")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data({"login" => email, "password" => password, "locale" => "es"})
    response = http.request(request)
    api_key = JSON.parse(response.body)["account"]["api_key"]
    # get de attendants hash
    uri = URI.parse("https://eventioz.com/admin/events/rubyconf-argentina-2011/registrations.json?api_key=#{api_key}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    attendants = JSON.parse(response.body)
    #puts attendants.map{|a| a["registration"]["email"]}
    attendants.map{|a| a["registration"]["email"]}.include?(email_attendant)
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
        if authenticate_eventioz(".com", "N", player_attributes["mail"])
          if player.save
            message = "La inscripcion se realizo con exito !!!"
          else
            player.errors.each do |e|
              message += e.join + " ,"
            end
          end
        else
          message = "Por favor controle su email no figura en la lista de pre registro de la RubyConf Argentina."
        end
        session["message"]= message
        res.redirect "/"
      end
    end
  end

end
