class CreateLocations < ActiveRecord::Migration[6.0]
  def change
    create_table :locations do |t|
      t.string :name
      t.text :description
      t.multi_polygon :bounds
      t.references :parent

      t.timestamps
    end

    add_reference :incarnations, :location, foreign_key: true, null: true
  end
end
