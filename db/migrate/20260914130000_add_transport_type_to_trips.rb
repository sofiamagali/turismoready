class AddTransportTypeToTrips < ActiveRecord::Migration[7.0]
  def change
    add_column :trips, :transport_type, :string, default: "airplane", null: false
  end
end
