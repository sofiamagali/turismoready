require "test_helper"

class TripTest < ActiveSupport::TestCase
  setup do
    @attributes = {
      destination: destinations(:bariloche),
      name: "Viaje de prueba",
      start_date: Date.new(2027, 8, 1),
      end_date: Date.new(2027, 8, 8),
      price: 500_000,
      available_slots: 10,
      board_type: "none"
    }
  end

  test "belongs to a destination and is active by default" do
    trip = Trip.new(@attributes)

    assert trip.valid?
    assert_equal destinations(:bariloche), trip.destination
    assert trip.active?
  end

  test "requires name, destination and dates" do
    trip = Trip.new(@attributes.merge(name: nil, destination: nil, start_date: nil, end_date: nil))

    assert_not trip.valid?
    assert trip.errors[:name].any?
    assert trip.errors[:destination].any?
    assert trip.errors[:start_date].any?
    assert trip.errors[:end_date].any?
  end

  test "rejects invalid price, slots and dates" do
    trip = Trip.new(@attributes.merge(price: 0, available_slots: -1, end_date: @attributes[:start_date]))

    assert_not trip.valid?
    assert trip.errors[:price].any?
    assert trip.errors[:available_slots].any?
    assert trip.errors[:start_date].any?
  end

  test "rejects invalid board type" do
    trip = Trip.new(@attributes.merge(board_type: "all_inclusive"))

    assert_not trip.valid?
    assert trip.errors[:board_type].any?
  end

  test "centralizes board type labels" do
    assert_equal "Sin pensión", Trip.new(board_type: "none").board_type_label
    assert_equal "Media pensión", Trip.new(board_type: "half_board").board_type_label
    assert_equal "Pensión completa", Trip.new(board_type: "full_board").board_type_label
  end
end
