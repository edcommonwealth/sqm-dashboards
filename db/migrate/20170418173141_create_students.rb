class CreateStudents < ActiveRecord::Migration[5.0]
  def change
    create_table :students do |t|
      t.string :name
      t.string :teacher
      t.date :birthdate
      t.string :gender
      t.string :age
      t.string :ethnicity
      t.integer :recipient_id

      t.timestamps
    end

    add_column :questions, :for_recipient_students, :boolean, default: false
    add_column :attempts, :student_id, :integer
  end
end
