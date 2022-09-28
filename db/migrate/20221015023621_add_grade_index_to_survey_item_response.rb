class AddGradeIndexToSurveyItemResponse < ActiveRecord::Migration[7.0]
  def change
    add_index :survey_item_responses, [:school_id, :survey_item_id, :academic_year_id, :grade], name: "index_survey_responses_on_grade"
  end
end
