require "test_helper"

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @buyer = User.create!(first_name: "Ana", last_name: "Compradora", email: "profile-buyer@example.com", password: "password123")
  end

  test "requires login" do
    get profile_path
    assert_redirected_to new_user_session_path
  end

  test "shows buyer profile without reservations" do
    sign_in @buyer
    get profile_path
    assert_response :success
    assert_select ".status-badge", text: "Comprador"
    assert_select "p", text: "Todavía no tenés viajes reservados."
  end

  test "shows only own trips including past trips and payment states" do
    paid = reserve(@buyer, "paid")
    unpaid = reserve(@buyer, "awaiting_payment")
    cancelled = reserve(@buyer, "cancelled")
    other = User.create!(first_name: "Otra", last_name: "Persona", email: "profile-other@example.com", password: "password123")
    hidden = reserve(other, "paid")
    paid.trip.update_columns(start_date: Date.new(2025, 1, 1), end_date: Date.new(2025, 1, 5), active: false)
    sign_in @buyer

    get profile_path

    assert_response :success
    [paid, unpaid, cancelled].each do |reservation|
      assert_select "a[href=?]", reservation_path(reservation), count: 1
    end
    assert_select "a[href=?]", reservation_path(hidden), count: 0
    assert_select "article p", text: "Pago: Pagado", count: 1
    assert_select "article p", text: "Pago: No pagado", count: 2
  end

  test "registration cannot grant administrative permissions" do
    post user_registration_path, params: { user: {
      first_name: "Nueva", last_name: "Compradora", email: "new-buyer@example.com",
      password: "password123", password_confirmation: "password123", admin: true, role: "admin"
    } }
    user = User.find_by!(email: "new-buyer@example.com")
    assert user.buyer?
    assert_equal "buyer", user.role
    assert_not user.admin?
  end

  private

  def reserve(user, status)
    reservation = user.reservations.new(trip: trips(:bariloche_winter), status: status)
    reservation.passengers.build(first_name: "Ana", last_name: "Viajera", dni: "30111222", birth_date: Date.new(1990, 1, 1))
    reservation.tap(&:save!)
  end
end
