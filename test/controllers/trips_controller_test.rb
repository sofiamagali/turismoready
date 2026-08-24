require "test_helper"

class TripsControllerTest < ActionDispatch::IntegrationTest
  setup do
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
    assert_select "button[disabled]", text: "Reservar"
  end

  test "creates a trip associated with a destination" do
    assert_difference("Trip.count", 1) do
      post trips_path, params: { trip: @valid_attributes }
    end

    created_trip = Trip.last
    assert_redirected_to trip_path(created_trip)
    assert_equal destinations(:mendoza), created_trip.destination
  end

  test "rejects invalid values" do
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
    patch trip_path(@trip), params: { trip: { name: "Bariloche Renovado" } }

    assert_redirected_to trip_path(@trip)
    assert_equal "Bariloche Renovado", @trip.reload.name
  end

  test "deactivates and reactivates a trip" do
    patch toggle_active_trip_path(@trip)
    assert_not @trip.reload.active?

    patch toggle_active_trip_path(@trip)
    assert @trip.reload.active?
  end
end
