require "test_helper"

class DestinationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @destination = destinations(:bariloche)
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
    assert_difference("Destination.count", 1) do
      post destinations_path, params: {
        destination: { name: "Ushuaia", country: "Argentina", city: "Ushuaia" }
      }
    end

    assert_redirected_to destination_path(Destination.last)
    assert Destination.last.active?
  end

  test "rejects destinations without each required field" do
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
    patch destination_path(@destination), params: { destination: { city: "Bariloche" } }

    assert_redirected_to destination_path(@destination)
    assert_equal "Bariloche", @destination.reload.city
  end

  test "deactivates and reactivates a destination" do
    patch toggle_active_destination_path(@destination)
    assert_not @destination.reload.active?

    patch toggle_active_destination_path(@destination)
    assert @destination.reload.active?
  end
end
