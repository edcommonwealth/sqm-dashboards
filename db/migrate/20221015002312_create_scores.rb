class CreateScores < ActiveRecord::Migration[7.0]
  def change
    create_table :scores do |t|
      t.float :average
      t.boolean :meets_teacher_threshold
      t.boolean :meets_student_threshold
      t.boolean :meets_admin_data_threshold
      t.integer :group
      t.references :measure, null: false, foreign_key: true
      t.references :school, null: false, foreign_key: true
      t.references :academic_year, null: false, foreign_key: true
      t.integer :grade
      t.references :race, null: false, foreign_key: true

      t.timestamps
    end
  end
end
