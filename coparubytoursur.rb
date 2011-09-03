# encoding: utf-8
require "cuba"
require "datamapper"
require "dm-sqlite-adapter"
require "haml"
require "json"
require "net/http"
require "net/https"
require "sass"
require 'tilt'
require 'yaml'

APP_CONFIG = YAML::load(File.read('config.yml'))

require File.expand_path('lib/models', File.dirname(__FILE__))

Cuba.use Rack::Static, :urls => [ "/js", "/images", "/fonts" ], :root => "public"
Cuba.use Rack::Session::Cookie

Cuba.define do
  
  def link_to(text, url=nil, options={}, &block)
    url, text = text, capture_haml(&block) if url.nil?
    capture_haml do
      haml_tag :a, text, options.merge(:href => url)
    end
  end

  def sass(file)
    Tilt.new(File.join(Dir.pwd, file)).render
  end

  def session
    @session ||= env['rack.session']
  end

  def flash(message = nil)
    if message.nil?
      session.delete('flash')
    else
      session['flash'] = message
    end
  end

  def players
    @players ||= Player.all(:order => [ :country.asc, :name.desc ])
  end

  on get do
    on "" do
      @player ||= Player.new
      res.write render('views/index.haml')
    end

    on 'website.css' do
      res.headers['Content-Type'] = "text/css"
      res.write sass('views/website.sass')
    end
  end

  # only POST requests
  on post do    
    message = ""
    on "players" do
      on param("player") do |player_attributes|
        @player ||= Player.new(player_attributes)
        if @player.save
          flash "La inscripción se realizó con éxito!!!"
          res.redirect "/"
        else
          res.write render('views/index.haml')
        end
      end
    end
  end

end
