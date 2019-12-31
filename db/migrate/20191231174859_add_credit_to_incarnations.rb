class AddCreditToIncarnations < ActiveRecord::Migration[6.0]
  def change
    add_column :incarnations, :credit, :text
  end
end
