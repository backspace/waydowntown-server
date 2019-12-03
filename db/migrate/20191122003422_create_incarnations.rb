class CreateIncarnations < ActiveRecord::Migration[6.0]
  def change
    create_table :incarnations do |t|
      t.string :concept_id

      t.timestamps
    end
  end
end
