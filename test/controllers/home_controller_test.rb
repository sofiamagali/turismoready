require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "offers transport categories without dates or prices" do
    get root_path
    assert_response :success
    assert_select "a[href=?]", destinations_path(transport_type: "bus"), text: /Viajes en micro/
    assert_select "a[href=?]", destinations_path(transport_type: "airplane"), text: /Viajes en avión/
    assert_select ".trip-card", count: 0
    assert_select ".price, .detail-price, .departure-card", count: 0
  end

  test "shows public authentication navigation" do
    get root_path

    assert_select "a", text: "Registrarse"
    assert_select "a", text: "Iniciar sesión"
  end
end
