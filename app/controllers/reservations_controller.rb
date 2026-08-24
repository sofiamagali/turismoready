class ReservationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_trip, only: %i[new create]
  before_action :set_reservation, only: %i[show edit update confirm]
  before_action :ensure_editable, only: %i[edit update]

  def new
    @reservation = current_user.reservations.new(trip: @trip)
    @passenger_count = requested_passenger_count
    @passenger_count.times { @reservation.passengers.build }
  end

  def create
    @reservation = current_user.reservations.new(reservation_params)
    @reservation.trip = @trip

    if @reservation.save
      redirect_to @reservation, notice: "Reserva creada correctamente."
    else
      @passenger_count = [@reservation.passengers.size, 1].max
      render :new, status: :unprocessable_entity
    end
  end

  def show; end

  def edit; end

  def update
    if @reservation.update(reservation_params)
      redirect_to @reservation, notice: "Reserva actualizada correctamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def confirm
    unless @reservation.pending?
      redirect_to @reservation, alert: "La reserva ya no puede confirmarse."
      return
    end

    @reservation.update!(status: "awaiting_payment")
    redirect_to @reservation, notice: "Reserva confirmada. El pago está pendiente."
  end

  private

  def set_trip
    @trip = Trip.find(params[:trip_id])
  end

  def set_reservation
    @reservation = current_user.reservations.includes(:passengers, trip: :destination).find(params[:id])
  end

  def ensure_editable
    return if @reservation.editable?

    redirect_to @reservation, alert: "Esta reserva ya no puede modificarse."
  end

  def requested_passenger_count
    count = params.fetch(:passenger_count, 1).to_i
    return 1 unless count.positive?

    [count, @trip.available_slots].min
  end

  def reservation_params
    params.require(:reservation).permit(passengers_attributes: %i[id first_name last_name dni birth_date nationality])
  end
end
