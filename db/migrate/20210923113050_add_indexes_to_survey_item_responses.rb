class AddIndexesToSurveyItemResponses < ActiveRecord::Migration[5.0]
  def change
    add_index :survey_item_responses, :school_id
    add_index :survey_item_responses, :survey_item_id
    add_index :survey_item_responses, :response_id
    add_index :survey_item_responses, :academic_year_id
  end
end
