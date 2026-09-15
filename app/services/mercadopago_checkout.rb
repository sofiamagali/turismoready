class MercadopagoCheckout
  def self.create!(reservation)
    raise "Mercado Pago no está configurado" unless MercadoPagoClient.configured?

    host = ENV.fetch("APP_HOST", "http://localhost:3100").chomp("/")
    preference_data = {
      items: [{
        title: "#{reservation.trip.name} - #{reservation.reservation_code}",
        quantity: 1,
        currency_id: "ARS",
        unit_price: reservation.total_price.to_f
      }],
      external_reference: reservation.reservation_code,
      payer: { email: reservation.user.email },
      back_urls: {
        success: "#{host}/reservations/#{reservation.id}",
        pending: "#{host}/reservations/#{reservation.id}",
        failure: "#{host}/reservations/#{reservation.id}"
      },
      notification_url: "#{host}/mercadopago/webhook"
    }
    # Mercado Pago no permite auto_return cuando la URL de retorno es local.
    preference_data[:auto_return] = "approved" unless host.match?(%r{\Ahttps?://(localhost|127\.0\.0\.1)(:\d+)?\z})
    result = MercadoPagoClient.instance.preference.create(preference_data)
    preference = result[:response]
    raise "Mercado Pago rechazó la preferencia (HTTP #{result[:status]}): #{preference.inspect}" unless result[:status].to_i.between?(200, 299) && preference["init_point"].present?

    preference["init_point"]
  end
end
