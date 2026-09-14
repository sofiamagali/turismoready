class DestinationsController < ApplicationController
  before_action :set_transport_type, only: %i[index show]
  before_action :authenticate_user!, except: %i[index show]
  before_action :require_admin!, except: %i[index show]
  before_action :set_destination, only: %i[show edit update toggle_active]

  def index
    @transport_type ||= "airplane"
    @destinations = Destination.order(:name)
    if @transport_type
      @destinations = @destinations.where(active: true).where(id: Trip.upcoming.where(transport_type: @transport_type).select(:destination_id))
    end
  end

  def show
    @transport_type ||= @destination.trips.upcoming.exists?(transport_type: "airplane") ? "airplane" : "bus"
    @trips = @destination.trips.upcoming.order(:start_date, :price, :name)
    @trips = @trips.where(transport_type: @transport_type) if @transport_type
    @program_trip = @trips.first
  end

  def new
    @destination = Destination.new
  end

  def create
    @destination = Destination.new(destination_params)

    if @destination.save
      redirect_to @destination, notice: "Destino creado correctamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @destination.update(destination_params)
      redirect_to @destination, notice: "Destino actualizado correctamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def toggle_active
    @destination.update!(active: !@destination.active?)
    status = @destination.active? ? "activado" : "desactivado"
    redirect_to destinations_path, notice: "Destino #{status} correctamente."
  end

  private

  def set_transport_type
    @transport_type = params[:transport_type].presence
    head :bad_request if @transport_type && !Trip::TRANSPORT_TYPES.key?(@transport_type)
  end

  def require_admin!
    head :forbidden unless current_user.admin?
  end

  def set_destination
    @destination = Destination.find(params[:id])
  end

  def destination_params
    params.require(:destination).permit(:name, :country, :city, :description, :image_url, :active)
  end
end
