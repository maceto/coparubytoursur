require "cuba"
require "haml"

Cuba.use Rack::Static, urls: [ "/public/styles", "/public/images" ]

Cuba.define do

  # only GET requests
  on get do
    # /
    on "" do
      res.write render('views/index.haml')
    end

  end


end
