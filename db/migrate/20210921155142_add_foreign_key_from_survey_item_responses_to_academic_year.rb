class AddForeignKeyFromSurveyItemResponsesToAcademicYear < ActiveRecord::Migration[5.0]
  def up
    remove_column :survey_item_responses, :academic_year
    add_column :survey_item_responses, :academic_year_id, :integer, null: false
    add_foreign_key :survey_item_responses, :academic_years
  end

  def down
    remove_foreign_key :survey_item_responses, :academic_years
    remove_column :survey_item_responses, :academic_year_id
    add_column :survey_item_responses, :academic_year, :string
  end
end
