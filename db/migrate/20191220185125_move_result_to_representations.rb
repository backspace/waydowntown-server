class MoveResultToRepresentations < ActiveRecord::Migration[6.0]
  def change
    add_column :representations, :result, :jsonb, null: false
    remove_column :participations, :result, :integer
  end
end
