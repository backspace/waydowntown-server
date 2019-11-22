class CreateIncarnations < ActiveRecord::Migration[6.0]
  def change
    create_table :incarnations do |t|
      t.references :concept, null: false, foreign_key: true

      t.timestamps
    end
  end
end
