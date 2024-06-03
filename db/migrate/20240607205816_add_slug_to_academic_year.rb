class AddSlugToAcademicYear < ActiveRecord::Migration[7.1]
  def change
    add_column :academic_years, :slug, :string
    add_index :academic_years, :slug, unique: true
  end
end
