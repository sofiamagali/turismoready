require "test_helper"
require Rails.root.join("lib/km1_bus_catalog")

class Km1BusCatalogTest < ActiveSupport::TestCase
  test "loads verified bus departures without duplicating them or inventing seats" do
    Km1BusCatalog.load!
    imported = Trip.where.not(source_url: nil)
    assert_equal 65, imported.count
    assert_equal 6, imported.distinct.count(:destination_id)
    assert imported.all? { |trip| trip.transport_type == "bus" && trip.available_slots.zero? }
    assert_equal Date.new(2027, 2, 3), imported.where(start_date: Date.new(2027, 1, 29)).first.end_date
    assert_no_difference(["Trip.count", "Destination.count"]) { Km1BusCatalog.load! }
  end
end
