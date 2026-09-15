class MercadopagoController < ActionController::API
  def webhook
    payment_id = params.dig(:data, :id) || params.dig("data", "id")
    return head :bad_request if payment_id.blank? || !MercadoPagoClient.configured?

    result = MercadoPagoClient.instance.payment.get(payment_id)
    payment = result[:response]
    reservation = Reservation.find_by(reservation_code: payment["external_reference"])
    return head :not_found unless reservation

    reservation.update!(status: "paid", mercadopago_payment_id: payment["id"].to_s) if payment["status"] == "approved"
    head :ok
  rescue StandardError => e
    Rails.logger.error("Mercado Pago webhook: #{e.class}: #{e.message}")
    head :unprocessable_entity
  end
end
