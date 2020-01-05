class AddCapabilitiesToMembers < ActiveRecord::Migration[6.0]
  def change
    add_column :members, :capabilities, :jsonb, null: false, default: {}
  end
end
