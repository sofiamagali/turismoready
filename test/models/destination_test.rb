require "test_helper"

class DestinationTest < ActiveSupport::TestCase
  test "is valid with required attributes" do
    assert Destination.new(name: "Ushuaia", country: "Argentina", city: "Ushuaia").valid?
  end

  test "requires name, country and city" do
    destination = Destination.new

    assert_not destination.valid?
    assert_includes destination.errors[:name], "can't be blank"
    assert_includes destination.errors[:country], "can't be blank"
    assert_includes destination.errors[:city], "can't be blank"
  end

  test "is active by default" do
    assert Destination.new.active?
  end
end
