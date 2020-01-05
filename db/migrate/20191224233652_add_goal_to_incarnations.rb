class AddGoalToIncarnations < ActiveRecord::Migration[6.0]
  def change
    add_column :incarnations, :goal, :jsonb, null: false
  end
end
