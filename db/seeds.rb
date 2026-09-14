destinations = [
  { name: "Bariloche", image_url: "/images/destinations/bariloche.jpg", country: "Argentina", city: "San Carlos de Bariloche", description: "Lagos, montañas y naturaleza en la Patagonia." },
  { name: "Mendoza", image_url: "/images/destinations/mendoza.jpg", country: "Argentina", city: "Mendoza", description: "Vinos, gastronomía y paisajes al pie de los Andes." },
  { name: "Ushuaia", image_url: "/images/destinations/ushuaia.jpg", country: "Argentina", city: "Ushuaia", description: "La ciudad más austral del mundo y puerta de entrada a Tierra del Fuego." },
  { name: "Río de Janeiro", image_url: "/images/destinations/rio-de-janeiro.jpg", country: "Brasil", city: "Río de Janeiro", description: "Playas, cultura y paisajes emblemáticos de Brasil." }
]

destinations.each do |attributes|
  destination = Destination.find_or_initialize_by(name: attributes[:name], country: attributes[:country])
  destination.update!(attributes)
end

trips = [
  { destination_name: "Bariloche", name: "Bariloche Invierno", start_date: Date.new(2027, 7, 10), end_date: Date.new(2027, 7, 17), price: 850_000, available_slots: 20, flight: "JetSMART - Buenos Aires → Bariloche", hotel: "Hotel Patagonia", board_type: "half_board" },
  { destination_name: "Mendoza", name: "Mendoza Escapada", start_date: Date.new(2027, 4, 8), end_date: Date.new(2027, 4, 12), price: 620_000, available_slots: 16, flight: "Aerolíneas Argentinas - Buenos Aires → Mendoza", hotel: "Hotel Diplomatic", board_type: "full_board" },
  { destination_name: "Ushuaia", name: "Ushuaia Fin del Mundo", start_date: Date.new(2027, 11, 3), end_date: Date.new(2027, 11, 9), price: 1_150_000, available_slots: 12, flight: "Flybondi - Buenos Aires → Ushuaia", hotel: "Hotel Canal Beagle", board_type: "half_board" },
  { destination_name: "Río de Janeiro", name: "Río de Janeiro Verano", start_date: Date.new(2027, 1, 15), end_date: Date.new(2027, 1, 22), price: 1_380_000, available_slots: 24, flight: "GOL - Buenos Aires → Río de Janeiro", hotel: "Hotel Atlântico", board_type: "none" }
]

trips.each do |attributes|
  destination = Destination.find_by!(name: attributes[:destination_name])
  attributes = attributes.except(:destination_name).merge(transport_type: "airplane")
  trip = Trip.find_or_initialize_by(destination: destination, name: attributes[:name])
  trip.update!(attributes)
end

require Rails.root.join("lib/km1_bus_catalog")
Km1BusCatalog.load!
