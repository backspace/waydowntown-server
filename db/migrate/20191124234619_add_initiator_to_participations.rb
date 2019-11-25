class AddInitiatorToParticipations < ActiveRecord::Migration[6.0]
  def change
    add_column :participations, :initiator, :boolean, default: false
  end
end
