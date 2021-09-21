class CreateAcademicYears < ActiveRecord::Migration[5.0]
  def change
    create_table :academic_years do |t|
      t.string :range, null: false, unique: true
      t.index :range, unique: true
    end
  end
end
