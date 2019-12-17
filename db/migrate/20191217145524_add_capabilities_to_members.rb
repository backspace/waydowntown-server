class AddCapabilitiesToMembers < ActiveRecord::Migration[6.0]
  def change
    add_column :members, :capabilities, :jsonb, default: {}
  end
end
