class CreateRepresentations < ActiveRecord::Migration[6.0]
  def change
    create_table :representations do |t|
      t.references :member, null: false, foreign_key: true
      t.references :participation, null: false, foreign_key: true
      t.boolean :representing

      t.timestamps
    end
  end
end
