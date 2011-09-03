# encoding: utf-8
DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/db/development.db")
DataMapper::Logger.new($stdout, :debug)

class Player

  include DataMapper::Resource

  property :id, Serial
  property :email, String, :required => true, :unique => true,
                          :format   => :email_address,
                          :messages => {
                            :presence  => 'El email es obligatorio.',
                            :is_unique => 'El email ingresado ya existe.',
                            :format    => 'El formato del email ingresado es erroneo'
                          }
  
  property :name, String
  property :twitter, String, :required => true
  property :country, String, :required => true

  validates_with_method :registered_on_eventioz?

  private
  
  def registered_on_eventioz?
    if @email and attendant
      puts attendant.inspect
      self.name = [attendant['first_name'], attendant['last_name']].join(" ")
      true
    else
      [ false, "Hey, parece que no estás registrado en Eventioz." ]
    end
  end

  def attendant
    @attendant ||= load_attendant 
  end

  def load_attendant
    fetch_attendants[@email]
  end

  def fetch_attendants
    puts "Fetching Attendants From Eventioz"
    url = "https://eventioz.com/admin/events/rubyconf-argentina-2011/registrations.json?api_key="
    responses = JSON.parse(getinfo(url, {
      :api_key => api_key, :verb => "get" 
    })).inject({}) do |hash, a|
      hash[a['registration']['email']] = a["registration"]
      hash 
    end
    responses
  end

  def api_key
    APP_CONFIG['eventioz_api_key'] || fetch_api_key
  end

  def fetch_api_key
    puts "Fetching API Key From Eventioz..."
    eventioz_user = APP_CONFIG['eventioz_user']
    eventioz_password = APP_CONFIG['eventioz_password'] 
    response = JSON.parse(getinfo("https://eventioz.com/session.json", {
      :user => eventioz_user, 
      :pass => eventioz_password, 
      :locale => "es", 
      :verb => "post"
    }))
    response["account"]["api_key"]
  end

  def getinfo(url, opts={})
    o = { :user => "test@mail.com", :pass => "password", :verb => "get", :locale => "es", :api_key => "cero" }.merge(opts)

    if o[:verb] == "post"
      uri = URI.parse(url)
    else
      uri = URI.parse(url + o[:api_key])
    end
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    if o[:verb] == "get"
      puts "get"
      request = Net::HTTP::Get.new(uri.request_uri)
    else
      puts "post"
      request = Net::HTTP::Post.new(uri.request_uri)
      request.set_form_data({"login" => o[:user], "password" => o[:pass], "locale" => o[:locale]})
    end
    response = http.request(request)
    response.body
  end
end

DataMapper.finalize
DataMapper.auto_upgrade!