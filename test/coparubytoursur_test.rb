require File.expand_path("../coparubytoursur", File.dirname(__FILE__))
require "cuba/test"

scope do
  test "load Homepage" do
    visit "/"
    assert has_content?("contenido")
  end
end

