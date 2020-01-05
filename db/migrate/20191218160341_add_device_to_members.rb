class AddDeviceToMembers < ActiveRecord::Migration[6.0]
  def change
    add_column :members, :device, :jsonb, null: false, default: {}
  end
end
