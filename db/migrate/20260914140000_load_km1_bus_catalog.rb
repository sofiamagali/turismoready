class LoadKm1BusCatalog < ActiveRecord::Migration[7.0]
  def up
    add_column :trips, :source_url, :string
    add_column :trips, :source_checked_on, :date
    Trip.reset_column_information
    require Rails.root.join("lib/km1_bus_catalog")
    Km1BusCatalog.load!
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "El catálogo contiene destinos y salidas que pueden haber sido editados."
  end
end
