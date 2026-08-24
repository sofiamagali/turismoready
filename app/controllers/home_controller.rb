class HomeController < ApplicationController
  def index
    @featured_trips = Trip.includes(:destination).where(active: true).order(:start_date).limit(4)
  end
end
