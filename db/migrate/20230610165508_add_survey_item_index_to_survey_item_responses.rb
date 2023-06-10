class AddSurveyItemIndexToSurveyItemResponses < ActiveRecord::Migration[7.0]
  def change
    add_index :survey_item_responses, %i[school_id academic_year_id survey_item_id],
              name: 'by_school_year_and_survey_item'
  end
end
