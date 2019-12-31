class AddCapabilitiesToLocations < ActiveRecord::Migration[6.0]
  def change
    add_column :locations, :capabilities, :string, array: true, default: []
  end
end
