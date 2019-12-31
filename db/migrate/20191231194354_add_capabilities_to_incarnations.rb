class AddCapabilitiesToIncarnations < ActiveRecord::Migration[6.0]
  def change
    add_column :incarnations, :capabilities, :string, array: true, default: []
  end
end
