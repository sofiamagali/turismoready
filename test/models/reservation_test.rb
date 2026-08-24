require "test_helper"

class ReservationTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(first_name: "Ana", last_name: "Viajera", email: "reservation-model@example.com", password: "password123")
    @trip = trips(:bariloche_winter)
  end

  test "calculates total and generates a unique reservation code" do
    first = build_reservation(2)
    second = build_reservation(1)

    assert first.save
    assert second.save
    assert_equal @trip.price * 2, first.total_price
    assert_match(/\ARES-[A-Z0-9]{6}\z/, first.reservation_code)
    assert_not_equal first.reservation_code, second.reservation_code
    assert_equal "pending", first.status
  end

  test "rejects reservations without passengers or above available slots" do
    empty = Reservation.new(user: @user, trip: @trip)
    assert_not empty.valid?
    assert empty.errors[:passengers].any?

    excessive = build_reservation(@trip.available_slots + 1)
    assert_not excessive.valid?
    assert excessive.errors[:passengers].any?
  end

  private

  def build_reservation(passenger_count)
    Reservation.new(user: @user, trip: @trip).tap do |reservation|
      passenger_count.times do |index|
        reservation.passengers.build(first_name: "Pasajero", last_name: index.to_s,
                                     dni: "30000#{index}", birth_date: Date.new(1990, 1, 1))
      end
    end
  end
end
