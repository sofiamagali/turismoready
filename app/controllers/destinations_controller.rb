class DestinationsController < ApplicationController
  before_action :set_destination, only: %i[show edit update toggle_active]

  def index
    @destinations = Destination.order(:name)
  end

  def show; end

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

  def set_destination
    @destination = Destination.find(params[:id])
  end

  def destination_params
    params.require(:destination).permit(:name, :country, :city, :description, :image_url, :active)
  end
end
