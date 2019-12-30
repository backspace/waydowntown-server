class AddQuestionsToIncarnations < ActiveRecord::Migration[6.0]
  def change
    add_column :incarnations, :questions, :jsonb
  end
end
