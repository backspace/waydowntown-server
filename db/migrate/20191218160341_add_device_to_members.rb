class AddDeviceToMembers < ActiveRecord::Migration[6.0]
  def change
    add_column :members, :device, :jsonb, default: {}
  end
end
