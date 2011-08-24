require File.expand_path("../coparubytoursur", File.dirname(__FILE__))
require "cuba/test"

scope do

  test "load Homepage" do
    visit "/"
    assert has_content?("Copa Ruby Tour Sur")
  end

  test "new player should has content on index" do
    visit "/"
    fill_in "player[name]", :with => "Jose Velez"
    fill_in "player[mail]", :with => "Jose@mail.com"
    fill_in "player[twitter]", :with => "@jose"
    select("Uruguay", :from => "player[country]")
    click_button('Send')
    assert has_content?("Jose Velez")
  end

end
