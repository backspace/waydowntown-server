class AddInstructionsToIncarnations < ActiveRecord::Migration[6.0]
  def change
    add_column :incarnations, :instructions, :text
  end
end
