class CreateRespondents < ActiveRecord::Migration[7.0]
  def change
    create_table :respondents do |t|
      t.references :school, null: false, foreign_key: true
      t.references :academic_year, null: false, foreign_key: true
      t.float :total_students
      t.float :total_teachers

      t.timestamps
    end
  end
end
