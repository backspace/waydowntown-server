class MoveResultToRepresentations < ActiveRecord::Migration[6.0]
  def change
    add_column :representations, :result, :integer
    remove_column :participations, :result, :integer
  end
end
