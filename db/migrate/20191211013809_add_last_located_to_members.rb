class AddLastLocatedToMembers < ActiveRecord::Migration[6.0]
  def change
    add_column :members, :last_located, :datetime
  end
end
