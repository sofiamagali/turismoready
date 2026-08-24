destinations = [
  { name: "Bariloche", country: "Argentina", city: "San Carlos de Bariloche", description: "Lagos, montañas y naturaleza en la Patagonia." },
  { name: "Mendoza", country: "Argentina", city: "Mendoza", description: "Vinos, gastronomía y paisajes al pie de los Andes." },
  { name: "Ushuaia", country: "Argentina", city: "Ushuaia", description: "La ciudad más austral del mundo y puerta de entrada a Tierra del Fuego." },
  { name: "Río de Janeiro", country: "Brasil", city: "Río de Janeiro", description: "Playas, cultura y paisajes emblemáticos de Brasil." }
]

destinations.each do |attributes|
  destination = Destination.find_or_initialize_by(name: attributes[:name], country: attributes[:country])
  destination.update!(attributes)
end
