class CreateTrips < ActiveRecord::Migration[7.0]
  def change
    create_table :trips do |t|
      t.references :destination, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.decimal :price, precision: 12, scale: 2, null: false
      t.integer :available_slots, null: false
      t.string :flight
      t.string :hotel
      t.string :board_type, null: false
      t.boolean :active, default: true, null: false

      t.timestamps
    end
  end
end
