class CreateSchoolCategories < ActiveRecord::Migration[5.0]
  def change
    create_table :school_categories do |t|
      t.references :school, foreign_key: true
      t.references :category, foreign_key: true
      t.integer :attempt_count, default: 0
      t.integer :response_count, default: 0
      t.integer :answer_index_total, default: 0

      t.timestamps
    end
  end
end
