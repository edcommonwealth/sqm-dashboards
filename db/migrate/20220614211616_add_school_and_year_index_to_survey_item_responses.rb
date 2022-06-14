class AddSchoolAndYearIndexToSurveyItemResponses < ActiveRecord::Migration[7.0]
  def change
    add_index :survey_item_responses, %i[school_id academic_year_id]
  end
end
