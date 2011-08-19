require File.expand_path("../coparubytoursur", File.dirname(__FILE__))
require "cuba/test"

scope do

  setup do
    @valid_attributes = {:name => "Julio", :mail => "email@mail.com", :twitter => "@twitter", :country => "Argentina" }
  end

  test "load Homepage" do
    visit "/"
    assert has_content?("Copa Ruby Tour Sur")
  end

  test "should not be valid post without a name" do |param|
    player = Player.new(@valid_attributes.merge(:name => nil))
    assert !player.valid?
  end

  test "should not be valid post without a mail" do |param|
    player = Player.new(@valid_attributes.merge(:mail => nil))
    assert !player.valid?
  end


  test "should not be valid post without a twitter" do |param|
    player = Player.new(@valid_attributes.merge(:twitter => nil))
    assert !player.valid?
  end

  test "should not be valid post without a country" do |param|
    player = Player.new(@valid_attributes.merge(:country => nil))
    assert !player.valid?
  end
end

