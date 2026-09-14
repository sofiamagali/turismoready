require "test_helper"

class TripsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin = User.create!(first_name: "Sofi", last_name: "Admin", email: "trip-admin@example.com", password: "password123", admin: true)
    @trip = trips(:bariloche_winter)
    @valid_attributes = {
      destination_id: destinations(:mendoza).id,
      name: "Nuevo viaje",
      start_date: "2027-09-01",
      end_date: "2027-09-05",
      price: "750000.00",
      available_slots: 8,
      board_type: "none"
    }
  end

  test "lists trips" do
    get trips_path

    assert_response :success
    assert_select "h3", text: @trip.name
    assert_select "h3", text: trips(:mendoza_escape).name, count: 0
  end

  test "shows a trip" do
    get trip_path(@trip)

    assert_response :success
    assert_select "h1", text: @trip.name
    assert_select "dd", text: "Media pensión"
    assert_select "a", text: "Reservar"
  end

  test "creates a trip associated with a destination" do
    sign_in @admin
    assert_difference("Trip.count", 1) do
      post trips_path, params: { trip: @valid_attributes }
    end

    created_trip = Trip.last
    assert_redirected_to trip_path(created_trip)
    assert_equal destinations(:mendoza), created_trip.destination
  end

  test "rejects invalid values" do
    sign_in @admin
    invalid_sets = [
      @valid_attributes.merge(price: 0),
      @valid_attributes.merge(available_slots: -1),
      @valid_attributes.merge(end_date: @valid_attributes[:start_date]),
      @valid_attributes.merge(board_type: "invalid")
    ]

    invalid_sets.each do |attributes|
      assert_no_difference("Trip.count") do
        post trips_path, params: { trip: attributes }
      end
      assert_response :unprocessable_entity
    end
  end

  test "updates a trip" do
    sign_in @admin
    patch trip_path(@trip), params: { trip: { name: "Bariloche Renovado" } }

    assert_redirected_to trip_path(@trip)
    assert_equal "Bariloche Renovado", @trip.reload.name
  end

  test "deactivates and reactivates a trip" do
    sign_in @admin
    patch toggle_active_trip_path(@trip)
    assert_not @trip.reload.active?

    patch toggle_active_trip_path(@trip)
    assert @trip.reload.active?
  end

  test "guests cannot manage trips" do
    get new_trip_path
    assert_redirected_to new_user_session_path
    assert_no_difference("Trip.count") do
      post trips_path, params: { trip: @valid_attributes }
    end
    assert_redirected_to new_user_session_path
  end

  test "regular users cannot manage trips" do
    user = User.create!(first_name: "Ana", last_name: "Viajera", email: "trip-user@example.com", password: "password123")
    sign_in user
    get new_trip_path
    assert_response :forbidden
    assert_no_difference("Trip.count") do
      post trips_path, params: { trip: @valid_attributes }
    end
    assert_response :forbidden
    patch trip_path(@trip), params: { trip: { name: "Cambio sin permiso" } }
    assert_response :forbidden
    patch toggle_active_trip_path(@trip)
    assert_response :forbidden
    assert @trip.reload.active?
  end

  test "only admins see the creation link and can open the form" do
    get trips_path
    assert_select "a[href=?]", new_trip_path, count: 0
    sign_in @admin
    get trips_path
    assert_select "a[href=?]", new_trip_path
    get new_trip_path
    assert_response :success
  end
end
