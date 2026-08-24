class CreateDestinations < ActiveRecord::Migration[7.0]
  def change
    create_table :destinations do |t|
      t.string :name
      t.string :country
      t.string :city
      t.text :description
      t.string :image_url
      t.boolean :active, default: true, null: false

      t.timestamps
    end
  end
end
