class ProfilesController < ApplicationController
  before_action :authenticate_user!

  def show
    @reservations = current_user.reservations.includes(trip: :destination).order(created_at: :desc, id: :desc)
  end
end
