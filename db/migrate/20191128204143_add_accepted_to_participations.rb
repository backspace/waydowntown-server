class AddAcceptedToParticipations < ActiveRecord::Migration[6.0]
  def change
    add_column :participations, :accepted, :boolean, default: false
  end
end
