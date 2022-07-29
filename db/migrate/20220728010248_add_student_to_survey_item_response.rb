class AddStudentToSurveyItemResponse < ActiveRecord::Migration[7.0]
  def change
    add_reference :survey_item_responses, :student, foreign_key: true
  end
end
