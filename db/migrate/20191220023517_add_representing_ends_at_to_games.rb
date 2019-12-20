class AddRepresentingEndsAtToGames < ActiveRecord::Migration[6.0]
  def change
    add_column :games, :representing_ends_at, :datetime
  end
end
