class AddImagesToBusDestinations < ActiveRecord::Migration[7.0]
  def up
    catalog = JSON.parse(File.read(Rails.root.join("db/catalogs/km1_bus_january_2027.json")))
    catalog.each do |entry|
      Destination.where(name: entry.fetch("name"), country: entry.fetch("country"), image_url: [nil, ""]).update_all(image_url: entry.fetch("image_url"))
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Las imágenes de destinos pueden haber sido editadas."
  end
end
