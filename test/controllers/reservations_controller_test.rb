require "test_helper"

class ReservationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = User.create!(first_name: "Ana", last_name: "Viajera", email: "reservation-flow@example.com", password: "password123")
    @other_user = User.create!(first_name: "Otra", last_name: "Persona", email: "other-reservation@example.com", password: "password123")
    @trip = trips(:bariloche_winter)
  end

  test "redirects unauthenticated user and continues after login" do
    get new_trip_reservation_path(@trip)
    assert_redirected_to new_user_session_path

    post user_session_path, params: { user: { email: @user.email, password: "password123" } }
    assert_redirected_to new_trip_reservation_path(@trip)
  end

  test "creates reservation with one passenger and server-calculated total" do
    sign_in @user

    assert_difference(["Reservation.count", "Passenger.count"], 1) do
      post trip_reservations_path(@trip), params: reservation_params(1, total_price: 1)
    end

    reservation = @user.reservations.last
    assert_redirected_to reservation_path(reservation)
    assert_equal @trip.price, reservation.total_price
    assert_match(/\ARES-[A-Z0-9]{6}\z/, reservation.reservation_code)
  end

  test "creates reservation with several passengers" do
    sign_in @user

    assert_difference("Passenger.count", 3) do
      post trip_reservations_path(@trip), params: reservation_params(3)
    end

    assert_equal @trip.price * 3, @user.reservations.last.total_price
  end

  test "buyer cannot mark a reservation as paid or change its owner" do
    sign_in @user
    post trip_reservations_path(@trip), params: reservation_params(1, status: "paid", user_id: @other_user.id)
    reservation = @user.reservations.last
    assert_equal "pending", reservation.status
    patch reservation_path(reservation), params: { reservation: { status: "paid", user_id: @other_user.id } }
    assert_equal "pending", reservation.reload.status
    assert_equal @user.id, reservation.user_id
  end

  test "rejects passenger count above available slots" do
    sign_in @user

    assert_no_difference("Reservation.count") do
      post trip_reservations_path(@trip), params: reservation_params(@trip.available_slots + 1)
    end
    assert_response :unprocessable_entity
  end

  test "blocks viewing another user's reservation" do
    reservation = create_reservation_for(@other_user)
    sign_in @user

    assert_raises(ActiveRecord::RecordNotFound) do
      get reservation_path(reservation)
    end
  end

  test "blocks confirmation of another user's reservation" do
    reservation = create_reservation_for(@other_user)
    sign_in @user

    assert_raises(ActiveRecord::RecordNotFound) do
      patch confirm_reservation_path(reservation)
    end
  end

  test "confirmation changes pending reservation to awaiting payment" do
    reservation = create_reservation_for(@user)
    sign_in @user

    patch confirm_reservation_path(reservation)

    assert_redirected_to reservation_path(reservation)
    assert_equal "awaiting_payment", reservation.reload.status
  end

  test "does not edit paid or cancelled reservations" do
    sign_in @user

    %w[paid cancelled].each do |status|
      reservation = create_reservation_for(@user)
      reservation.update_column(:status, status)
      original_name = reservation.passengers.first.first_name

      patch reservation_path(reservation), params: {
        reservation: { passengers_attributes: { "0" => { id: reservation.passengers.first.id, first_name: "Modificado" } } }
      }

      assert_redirected_to reservation_path(reservation)
      assert_equal original_name, reservation.passengers.first.reload.first_name
    end
  end

  private

  def reservation_params(count, extra = {})
    passengers = count.times.to_h do |index|
      [index.to_s, { first_name: "Nombre #{index}", last_name: "Apellido #{index}",
                     dni: "40000#{index}", birth_date: "1990-01-01", nationality: "Argentina" }]
    end

    { reservation: { passengers_attributes: passengers }.merge(extra) }
  end

  def create_reservation_for(user)
    reservation = user.reservations.new(trip: @trip)
    reservation.passengers.build(first_name: "Ana", last_name: "Viajera", dni: "30111222", birth_date: Date.new(1990, 1, 1))
    reservation.tap(&:save!)
  end
end
