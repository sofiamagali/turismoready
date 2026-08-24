class CreateReservations < ActiveRecord::Migration[7.0]
  def change
    create_table :reservations do |t|
      t.references :user, null: false, foreign_key: true
      t.references :trip, null: false, foreign_key: true
      t.string :status, null: false, default: "pending"
      t.decimal :total_price, precision: 12, scale: 2, null: false
      t.string :reservation_code, null: false

      t.timestamps
    end

    add_index :reservations, :reservation_code, unique: true
  end
end
