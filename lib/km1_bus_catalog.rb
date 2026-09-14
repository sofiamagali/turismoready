require "json"

module Km1BusCatalog
  def self.load!
    catalog = JSON.parse(File.read(Rails.root.join("db/catalogs/km1_bus_january_2027.json")))
    Destination.transaction do
      catalog.each do |entry|
        destination = Destination.find_or_initialize_by(name: entry.fetch("name"), country: entry.fetch("country"))
        destination.assign_attributes(city: entry.fetch("city"), description: entry.fetch("description")) if destination.new_record?
        destination.image_url = entry.fetch("image_url") if destination.image_url.blank?
        destination.assign_attributes(entry.slice("general_details", "excursions", "hotel_details", "itinerary", "boarding_points")) if destination.has_attribute?(:general_details)
        destination.save!
        entry.fetch("days").each do |day|
          date = Date.new(2027, 1, day)
          trip = Trip.find_or_initialize_by(destination: destination, source_url: entry.fetch("source_url"), start_date: date, transport_type: "bus")
          next if trip.persisted?

          trip.update!(name: "#{entry.fetch('name')} — #{entry.fetch('circuit')}",
                       end_date: date + entry.fetch("duration"), price: entry.fetch("price"),
                       board_type: entry.fetch("board_type"), hotel: entry.fetch("hotel"),
                       flight: "Micro semicama · ida y vuelta", available_slots: 0, active: true,
                       source_checked_on: Date.new(2026, 9, 14),
                       description: "Tarifa de referencia publicada por Kilómetro Uno para enero de 2027. Preventa para reservas antes del 20/09/2026. No incluye todos los gastos, tasas, entradas ni seguro. Precio y disponibilidad sujetos a confirmación con el proveedor.")
        end
      end
      Trip.where(transport_type: "bus", source_url: nil).where("description LIKE ?", "Paquete de ejemplo en micro a %").update_all(active: false)
    end
  end
end
