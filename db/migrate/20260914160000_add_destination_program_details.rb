class AddDestinationProgramDetails < ActiveRecord::Migration[7.0]
  def up
    %i[general_details excursions hotel_details itinerary boarding_points].each do |field|
      add_column :destinations, field, :text
    end
    add_column :destinations, :shared_bus_slots, :integer
    Destination.reset_column_information
    JSON.parse(File.read(Rails.root.join("db/catalogs/km1_bus_january_2027.json"))).each do |entry|
      destination = Destination.find_by!(name: entry.fetch("name"), country: entry.fetch("country"))
      destination.trips.where(transport_type: "bus").where.not(source_url: nil).update_all(description: "Viaje en micro a #{destination.name} con alojamiento y #{Trip::BOARD_TYPES.fetch(entry.fetch('board_type')).downcase}.")
      destination.update!(entry.slice("general_details", "excursions", "hotel_details", "itinerary", "boarding_points"))
    end
    merlo = Destination.find_by!(name: "Villa de Merlo", country: "Argentina")
    merlo.update!(shared_bus_slots: 2567)
    merlo.trips.where(transport_type: "bus").where.not(source_url: nil).update_all(available_slots: 2567)
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Los cupos y detalles pueden haber sido editados."
  end
end
