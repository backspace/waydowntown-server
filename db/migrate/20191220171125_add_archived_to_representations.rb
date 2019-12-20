class AddArchivedToRepresentations < ActiveRecord::Migration[6.0]
  def change
    add_column :representations, :archived, :boolean
  end
end
