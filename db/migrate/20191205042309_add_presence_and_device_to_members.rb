class AddPresenceAndDeviceToMembers < ActiveRecord::Migration[6.0]
  def change
    add_column :members, :last_subscribed, :datetime
    add_column :members, :last_unsubscribed, :datetime
    add_column :members, :registration_id, :string
    add_column :members, :registration_type, :string
  end
end
