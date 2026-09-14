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

  test "shared capacity blocks another departure and cancellation restores seats" do
    @trip.destination.update!(shared_bus_slots: 2)
    @trip.update!(transport_type: "bus", source_url: "https://example.com/program", available_slots: 2)
    other = @trip.destination.trips.create!(@trip.attributes.except("id", "created_at", "updated_at").merge(name: "Otra salida"))
    reservation = build_reservation(2)
    assert reservation.save
    assert_equal 0, @trip.reload.remaining_slots
    assert_equal 0, other.reload.remaining_slots
    assert @trip.destination.complete?
    blocked = build_reservation(1)
    blocked.trip = other
    assert_not blocked.save
    assert reservation.update(status: "cancelled")
    assert_equal 2, other.reload.remaining_slots
    assert_equal 2, @trip.reload.available_slots
  end

  test "editing and confirming a reservation do not consume seats twice" do
    reservation = build_reservation(2)
    assert reservation.save
    assert_equal 18, @trip.reload.available_slots
    assert reservation.update(status: "awaiting_payment")
    assert_equal 18, @trip.reload.available_slots
    assert reservation.update(passengers_attributes: [{ id: reservation.passengers.first.id, first_name: "Cambio" }])
    assert_equal 18, @trip.reload.available_slots
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
