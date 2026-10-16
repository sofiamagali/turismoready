require "mercadopago"

module MercadoPagoClient
  def self.instance
    @instance ||= Mercadopago::SDK.new(ENV.fetch("MERCADOPAGO_ACCESS_TOKEN"))
  end

  def self.configured?
    ENV["MERCADOPAGO_ACCESS_TOKEN"].present?
  end
end
