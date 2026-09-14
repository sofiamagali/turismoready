require "test_helper"
require Rails.root.join("lib/km1_bus_catalog")

class Km1BusCatalogTest < ActiveSupport::TestCase
  test "loads verified bus departures without duplicating them and with configured capacity" do
    Km1BusCatalog.load!
    imported = Trip.where.not(source_url: nil)
    assert_equal 65, imported.count
    assert_equal 6, imported.distinct.count(:destination_id)
    assert imported.all? { |trip| trip.transport_type == "bus" }
    imported.each do |trip|
      expected = Km1BusCatalog::COMPLETE_DEPARTURES.include?([trip.destination.name, trip.start_date]) ? 0 : Km1BusCatalog::DEFAULT_AVAILABLE_SLOTS
      assert_equal expected, trip.available_slots
    end
    assert_equal Date.new(2027, 2, 3), imported.where(start_date: Date.new(2027, 1, 29)).first.end_date
    assert_no_difference(["Trip.count", "Destination.count"]) { Km1BusCatalog.load! }
  end
end
