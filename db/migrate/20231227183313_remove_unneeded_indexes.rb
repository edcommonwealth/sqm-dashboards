class RemoveUnneededIndexes < ActiveRecord::Migration[7.1]
  def change
    remove_index :student_races, name: "index_student_races_on_student_id", column: :student_id
  end
end
