class AddForeignKeyBetweenSchoolsAndDistricts < ActiveRecord::Migration[7.0]
  def change
    add_foreign_key :schools, :districts
  end
end
