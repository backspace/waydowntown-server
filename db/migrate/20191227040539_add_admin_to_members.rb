class AddAdminToMembers < ActiveRecord::Migration[6.0]
  def change
    add_column :members, :admin, :boolean
  end
end
