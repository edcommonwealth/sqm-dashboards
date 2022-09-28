class AddGradeToSurveyItemResponse < ActiveRecord::Migration[7.0]
  def change
    add_column :survey_item_responses, :grade, :integer
  end
end
