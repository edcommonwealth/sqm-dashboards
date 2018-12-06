class AddStudentAndTeaceherCountToSchools < ActiveRecord::Migration[5.0]
  def change
    add_column :schools, :student_count, :integer
    add_column :schools, :teacher_count, :integer
  end
end
