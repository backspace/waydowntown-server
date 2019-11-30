class AddBeginsAtToGames < ActiveRecord::Migration[6.0]
  def change
    add_column :games, :begins_at, :datetime
  end
end
