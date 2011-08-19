require File.expand_path("../coparubytoursur", File.dirname(__FILE__))
require "cuba/test"

scope do

  setup do
    @valid_attributes = {:name => "Julio", :mail => "email@mail.com", :twitter => "@twitter" }
  end

  test "load Homepage" do
    visit "/"
    assert has_content?("contenido")
  end

  test "should not save post without name" do |param|
    player = Player.new(@valid_attributes.merge(:name => nil))
    assert !player.save
  end

  test "should not save post without mail" do |param|
    player = Player.new(@valid_attributes.merge(:mail => nil))
    assert !player.save
  end


  test "should not save post without twitter" do |param|
    player = Player.new(@valid_attributes.merge(:twitter => nil))
    assert !player.save
  end
end

