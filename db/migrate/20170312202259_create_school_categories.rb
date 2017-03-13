class CreateSchoolCategories < ActiveRecord::Migration[5.0]
  def change
    create_table :school_categories do |t|
      t.references :school, foreign_key: true
      t.references :category, foreign_key: true
      t.integer :attempt_count
      t.integer :response_count
      t.integer :answer_index_total

      t.timestamps
    end
  end
end
