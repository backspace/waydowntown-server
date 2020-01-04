class AddPositionToIncarnations < ActiveRecord::Migration[6.0]
  def change
    add_column :incarnations, :lat, :decimal
    add_column :incarnations, :lon, :decimal
  end
end
