class AddAasmStateToParticipations < ActiveRecord::Migration[6.0]
  def change
    add_column :participations, :aasm_state, :string
  end
end
