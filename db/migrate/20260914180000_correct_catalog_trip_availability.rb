class CorrectCatalogTripAvailability < ActiveRecord::Migration[7.0]
  def up
    require Rails.root.join("lib/km1_bus_catalog")
    catalog = JSON.parse(File.read(Rails.root.join("db/catalogs/km1_bus_january_2027.json")))
    catalog.each do |entry|
      departures = Trip.where(transport_type: "bus", source_url: entry.fetch("source_url"),
                              start_date: entry.fetch("days").map { |day| Date.new(2027, 1, day) })
      departures.where(available_slots: 0).update_all(available_slots: Km1BusCatalog::DEFAULT_AVAILABLE_SLOTS)
      complete_dates = Km1BusCatalog::COMPLETE_DEPARTURES.filter_map { |name, date| date if name == entry.fetch("name") }
      departures.where(start_date: complete_dates).update_all(available_slots: 0)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Los cupos previos del catálogo no pueden recuperarse."
  end
end
