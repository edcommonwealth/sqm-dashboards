class CreateResponseRates < ActiveRecord::Migration[7.0]
  def change
    create_table :response_rates do |t|
      t.references :subcategory, null: false, foreign_key: true
      t.references :school, null: false, foreign_key: true
      t.references :academic_year, null: false, foreign_key: true
      t.float :student_response_rate
      t.float :teacher_response_rate
      t.boolean :meets_student_threshold
      t.boolean :meets_teacher_threshold

      t.timestamps
    end

    add_index :response_rates, %i[school_id subcategory_id]
  end
end
