class SeparateTripProgramDetails < ActiveRecord::Migration[7.0]
  def up
    %i[general_details excursions hotel_details itinerary boarding_points].each do |field|
      add_column :trips, field, :text
    end
    Trip.reset_column_information
    Trip.includes(:destination).find_each do |trip|
      if trip.transport_type == "bus"
        trip.update!(trip.destination.attributes.slice("general_details", "excursions", "hotel_details", "itinerary", "boarding_points"))
      else
        trip.update!(
          description: "Viaje en avión a #{trip.destination.name}, con alojamiento en #{trip.hotel.presence || 'hotel a confirmar'} y régimen #{trip.board_type_label.downcase}.",
          general_details: "Viaje en avión.\nVuelo: #{trip.flight.presence || 'A confirmar'}.\nEstadía: #{(trip.end_date - trip.start_date).to_i} noches.\nRégimen: #{trip.board_type_label}.\nEquipaje: consultar las condiciones de la tarifa aérea.\nTraslados entre aeropuerto y hotel: consultar si están incluidos.",
          hotel_details: trip.hotel.presence || "Hotel a confirmar.",
          excursions: "Consultar las excursiones incluidas y opcionales de este paquete aéreo.",
          itinerary: "#{trip.start_date.strftime('%d/%m/%Y')}: salida en avión hacia #{trip.destination.name}.\nEstadía en destino según el programa contratado.\n#{trip.end_date.strftime('%d/%m/%Y')}: regreso en avión.\nLos horarios y aeropuertos se informan con la documentación del vuelo.",
          boarding_points: "Presentación en el aeropuerto indicado en el pasaje.\nConsultar terminal, horario y anticipación requerida por la aerolínea."
        )
      end
    end
  end

  def down
    %i[general_details excursions hotel_details itinerary boarding_points].each do |field|
      remove_column :trips, field
    end
  end
end
