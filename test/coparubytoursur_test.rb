require "cuba/test"

scope do
  test "load Homepage" do
    visit "/"
    assert has_content?("contenido")
  end
end

