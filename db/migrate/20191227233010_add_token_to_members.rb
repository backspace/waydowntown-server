class AddTokenToMembers < ActiveRecord::Migration[6.0]
  def up
    add_column :members, :token, :string

    Member.all.each{|m| m.update(token: SecureRandom.uuid) }
  end

  def down
    remove_column :members, :token, :string
  end
end
