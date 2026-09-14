class TripsController < ApplicationController
  before_action :set_trip, only: %i[show edit update toggle_active]
  before_action :set_destinations, only: %i[new create edit update]

  def index
    @trips = Trip.includes(:destination).where(active: true).order(:start_date, :name)
  end

  def show; end

  def new
    @trip = Trip.new
  end

  def create
    @trip = Trip.new(trip_params)

    if @trip.save
      redirect_to @trip, notice: "Viaje creado correctamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @trip.update(trip_params)
      redirect_to @trip, notice: "Viaje actualizado correctamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def toggle_active
    @trip.update!(active: !@trip.active?)
    status = @trip.active? ? "activado" : "desactivado"
    redirect_to trips_path, notice: "Viaje #{status} correctamente."
  end

  private

  def set_trip
    @trip = Trip.find(params[:id])
  end

  def set_destinations
    @destinations = Destination.order(:name)
  end

  def trip_params
    params.require(:trip).permit(:destination_id, :name, :description, :start_date,
                                 :end_date, :price, :available_slots, :flight, :hotel,
                                 :board_type, :active, :transport_type)
  end
end
