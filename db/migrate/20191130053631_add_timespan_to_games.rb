class AddTimespanToGames < ActiveRecord::Migration[6.0]
  def change
    add_column :games, :begins_at, :datetime
    add_column :games, :ends_at, :datetime
  end
end
