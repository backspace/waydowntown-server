class AddRatingsToIncarnationsAndLocations < ActiveRecord::Migration[6.0]
  def change
    add_column :incarnations, :awesomeness, :integer, default: 0
    add_column :incarnations, :risk, :integer, default: 0

    add_column :locations, :awesomeness, :integer, default: 0
    add_column :locations, :risk, :integer, default: 0
  end
end
