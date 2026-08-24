require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "shows only active featured trips with friendly board labels" do
    get root_path

    assert_response :success
    assert_select "h3", text: trips(:bariloche_winter).name
    assert_select "h3", text: trips(:mendoza_escape).name, count: 0
    assert_select ".trip-card", text: /Media pensión/
  end

  test "shows public authentication navigation" do
    get root_path

    assert_select "a", text: "Registrarse"
    assert_select "a", text: "Iniciar sesión"
  end
end
