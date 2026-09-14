class Destination < ApplicationRecord
  has_many :trips, dependent: :restrict_with_error

  validates :name, :country, :city, presence: true
  validates :shared_bus_slots, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true

  def complete?(transport_type = nil)
    departures = trips.upcoming
    departures = departures.where(transport_type: transport_type) if transport_type.present?
    departures.any? && departures.none? { |trip| trip.remaining_slots.positive? }
  end
end
