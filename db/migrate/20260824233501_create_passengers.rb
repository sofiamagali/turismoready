class CreatePassengers < ActiveRecord::Migration[7.0]
  def change
    create_table :passengers do |t|
      t.references :reservation, null: false, foreign_key: true
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :dni, null: false
      t.date :birth_date, null: false
      t.string :nationality

      t.timestamps
    end
  end
end
