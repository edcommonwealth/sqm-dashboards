class AddIndexToStudentRaces < ActiveRecord::Migration[7.0]
  def change
    add_index :student_races, %i[student_id race_id]
  end
end
