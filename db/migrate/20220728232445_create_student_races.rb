class CreateStudentRaces < ActiveRecord::Migration[7.0]
  def change
    create_table :student_races do |t|
      t.references :student, null: false, foreign_key: true
      t.references :race, null: false, foreign_key: true

      t.timestamps
    end
  end
end
