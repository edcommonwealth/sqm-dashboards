class DropRaceScores < ActiveRecord::Migration[7.0]
  def up
    drop_table :race_scores
  end

  def down
    create_table :race_scores do |t|
      t.references :measure, null: false, foreign_key: true
      t.references :school, null: false, foreign_key: true
      t.references :academic_year, null: false, foreign_key: true
      t.references :race, null: false, foreign_key: true
      t.float :average
      t.boolean :meets_student_threshold

      t.timestamps
    end
  end
end
