class AddResultToParticipations < ActiveRecord::Migration[6.0]
  def change
    add_column :participations, :result, :integer
  end
end
