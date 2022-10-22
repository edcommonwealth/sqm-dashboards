class AddGenderToSurveyItemResponses < ActiveRecord::Migration[7.0]
  def change
    add_reference :survey_item_responses, :gender, foreign_key: true
  end
end
