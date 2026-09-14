require "test_helper"

class DestinationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @destination = destinations(:bariloche)
    @admin = User.create!(first_name: "Ana", last_name: "Admin", email: "destination-admin@example.com", password: "password123", admin: true)
  end

  test "lists destinations" do
    get destinations_path

    assert_response :success
    assert_select "h2", text: @destination.name
  end

  test "shows a destination" do
    get destination_path(@destination)

    assert_response :success
    assert_select "h1", text: @destination.name
  end

  test "creates a valid destination" do
    sign_in @admin
    assert_difference("Destination.count", 1) do
      post destinations_path, params: {
        destination: { name: "Ushuaia", country: "Argentina", city: "Ushuaia" }
      }
    end

    assert_redirected_to destination_path(Destination.last)
    assert Destination.last.active?
  end

  test "rejects destinations without each required field" do
    sign_in @admin
    %i[name country city].each do |missing_attribute|
      attributes = { name: "Mendoza", country: "Argentina", city: "Mendoza" }
      attributes[missing_attribute] = ""

      assert_no_difference("Destination.count") do
        post destinations_path, params: { destination: attributes }
      end
      assert_response :unprocessable_entity
    end
  end

  test "updates a destination" do
    sign_in @admin
    patch destination_path(@destination), params: { destination: { city: "Bariloche" } }

    assert_redirected_to destination_path(@destination)
    assert_equal "Bariloche", @destination.reload.city
  end

  test "deactivates and reactivates a destination" do
    sign_in @admin
    patch toggle_active_destination_path(@destination)
    assert_not @destination.reload.active?

    patch toggle_active_destination_path(@destination)
    assert @destination.reload.active?
  end

  test "visitors see destinations without management actions" do
    get destinations_path
    assert_response :success
    assert_select "a[href=?]", new_destination_path, count: 0
    assert_select "a[href=?]", edit_destination_path(@destination), count: 0
    assert_select "form[action=?]", toggle_active_destination_path(@destination), count: 0

    get destination_path(@destination)
    assert_response :success
    assert_select "a[href=?]", edit_destination_path(@destination), count: 0
    assert_select "form[action=?]", toggle_active_destination_path(@destination), count: 0
  end

  test "visitors must sign in for all management actions" do
    get new_destination_path
    assert_redirected_to new_user_session_path
    get edit_destination_path(@destination)
    assert_redirected_to new_user_session_path
    assert_no_difference("Destination.count") do
      post destinations_path, params: { destination: { name: "Ushuaia", country: "Argentina", city: "Ushuaia" } }
    end
    assert_redirected_to new_user_session_path
    patch destination_path(@destination), params: { destination: { name: "Changed" } }
    assert_redirected_to new_user_session_path
    assert_equal "Bariloche", @destination.reload.name
    patch toggle_active_destination_path(@destination)
    assert_redirected_to new_user_session_path
    assert @destination.reload.active?
  end

  test "regular users cannot manage destinations even through direct requests" do
    user = User.create!(first_name: "Ana", last_name: "Viajera", email: "destination-user@example.com", password: "password123")
    assert_not user.admin?
    sign_in user
    get new_destination_path
    assert_response :forbidden
    get edit_destination_path(@destination)
    assert_response :forbidden
    assert_no_difference("Destination.count") do
      post destinations_path, params: { destination: { name: "Ushuaia", country: "Argentina", city: "Ushuaia" } }
    end
    assert_response :forbidden
    patch destination_path(@destination), params: { destination: { name: "Changed" } }
    assert_response :forbidden
    assert_equal "Bariloche", @destination.reload.name
    patch toggle_active_destination_path(@destination)
    assert_response :forbidden
    assert @destination.reload.active?
    get destinations_path
    assert_response :success
    assert_select "a[href=?]", edit_destination_path(@destination), count: 0
    get destination_path(@destination)
    assert_response :success
    assert_select "a[href=?]", edit_destination_path(@destination), count: 0
  end

  test "admins can access management forms and actions" do
    sign_in @admin
    get destinations_path
    assert_select "a[href=?]", new_destination_path
    assert_select "a[href=?]", edit_destination_path(@destination)
    get new_destination_path
    assert_response :success
    get edit_destination_path(@destination)
    assert_response :success
  end

  test "public registration cannot grant admin privileges" do
    assert_difference("User.count") do
      post user_registration_path, params: { user: { first_name: "Ana", last_name: "Viajera", email: "self-admin@example.com", password: "password123", password_confirmation: "password123", admin: true } }
    end
    assert_not User.find_by!(email: "self-admin@example.com").admin?
  end

  test "shows upcoming active departures for this destination ordered by date with prices" do
    first = trips(:bariloche_winter)
    first.update!(start_date: Date.current + 20, end_date: Date.current + 27)
    later = @destination.trips.create!(first.attributes.except("id", "created_at", "updated_at").merge(name: "Segunda salida", start_date: Date.current + 40, end_date: Date.current + 47, price: 950000, available_slots: 0))
    inactive = @destination.trips.create!(first.attributes.except("id", "created_at", "updated_at").merge(name: "Salida inactiva", active: false))
    past = @destination.trips.create!(first.attributes.except("id", "created_at", "updated_at").merge(name: "Salida pasada", start_date: Date.current - 20, end_date: Date.current - 13))
    other = trips(:mendoza_escape)
    other.update!(active: true, start_date: Date.current + 10, end_date: Date.current + 15)

    get destination_path(@destination)
    assert_response :success
    assert_select ".departure-card h3", text: first.name
    assert_select ".departure-card h3", text: later.name
    assert_select ".departure-card h3", text: inactive.name, count: 0
    assert_select ".departure-card h3", text: past.name, count: 0
    assert_select ".departure-card h3", text: other.name, count: 0
    assert_select ".departure-card h3" do |headings|
      assert_equal [first.name, later.name], headings.map(&:text)
    end
    [first, later].each do |trip|
      assert_select ".departure-card dd", text: trip.start_date.strftime("%d/%m/%Y")
      assert_select ".departure-card dd", text: trip.end_date.strftime("%d/%m/%Y")
      assert_select ".departure-card a[href=?]", trip_path(trip)
    end
    assert_select ".departure-card .detail-price", text: "$850.000"
    assert_select ".departure-card .detail-price", text: "$950.000"
    assert_select ".departure-card", text: /Sin cupos/
  end

  test "shows empty state when destination has no upcoming departures" do
    @destination.trips.update_all(active: false)
    get destination_path(@destination)
    assert_response :success
    assert_select ".departure-card", count: 0
    assert_select ".empty-state h3", text: "No hay próximas salidas disponibles."
  end

  test "transport categories list only matching destinations and preserve selection" do
    flight = trips(:bariloche_winter)
    flight.update!(start_date: Date.current + 20, end_date: Date.current + 27)
    bus = trips(:mendoza_escape)
    bus.destination.update!(active: true)
    bus.update!(active: true, transport_type: "bus", start_date: Date.current + 10, end_date: Date.current + 15)
    get destinations_path(transport_type: "bus")
    assert_response :success
    assert_select ".destination-card h2", text: destinations(:mendoza).name
    assert_select ".destination-card h2", text: @destination.name, count: 0
    assert_select "a[href=?]", destination_path(bus.destination, transport_type: "bus")
    assert_select ".price, .detail-price, .departure-card", count: 0
    get destinations_path(transport_type: "airplane")
    assert_select ".destination-card h2", text: @destination.name
    assert_select ".destination-card h2", text: bus.destination.name, count: 0
    flight.update!(active: false)
    get destinations_path(transport_type: "airplane")
    assert_select ".destination-card", count: 0
  end

  test "destination departure dates and prices follow selected transport" do
    flight = trips(:bariloche_winter)
    flight.update!(start_date: Date.current + 20, end_date: Date.current + 27)
    bus = @destination.trips.create!(flight.attributes.except("id", "created_at", "updated_at").merge(name: "Bariloche en micro", transport_type: "bus", price: 450000))
    get destination_path(@destination, transport_type: "bus")
    assert_response :success
    assert_select ".departure-card h3", text: bus.name
    assert_select ".departure-card h3", text: flight.name, count: 0
    assert_select ".detail-price", text: "$450.000"
    assert_select "a[href=?]", destinations_path(transport_type: "bus")
    get destination_path(@destination, transport_type: "airplane")
    assert_select ".departure-card h3", text: flight.name
    assert_select ".departure-card h3", text: bus.name, count: 0
  end

  test "rejects unknown transport categories" do
    get destinations_path(transport_type: "unknown")
    assert_response :bad_request
    get destination_path(@destination, transport_type: "unknown")
    assert_response :bad_request
  end
end
