class AddDurationToIncarnations < ActiveRecord::Migration[6.0]
  def change
    add_column :incarnations, :duration, :integer
  end
end
