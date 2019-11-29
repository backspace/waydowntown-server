class CreateMembers < ActiveRecord::Migration[6.0]
  def change
    create_table :members do |t|
      t.string :name
      t.decimal :lat
      t.decimal :lon
      t.references :team, null: false, foreign_key: true

      t.timestamps
    end
  end
end
