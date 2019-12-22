class AddScoringFields < ActiveRecord::Migration[6.0]
  def change
    add_column :participations, :winner, :boolean
    add_column :participations, :score, :decimal, precision: 10, scale: 6
  end
end
