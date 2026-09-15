class AddMercadopagoPaymentIdToReservations < ActiveRecord::Migration[7.0]
  def change
    add_column :reservations, :mercadopago_payment_id, :string
    add_index :reservations, :mercadopago_payment_id, unique: true
  end
end
