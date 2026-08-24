require "test_helper"

class PassengerTest < ActiveSupport::TestCase
  test "requires identity and birth date" do
    passenger = Passenger.new

    assert_not passenger.valid?
    assert passenger.errors[:first_name].any?
    assert passenger.errors[:last_name].any?
    assert passenger.errors[:dni].any?
    assert passenger.errors[:birth_date].any?
  end
end
