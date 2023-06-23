class AddRecordedDateToSurveyItemResponse < ActiveRecord::Migration[7.0]
  def change
    add_column :survey_item_responses, :recorded_date, :datetime
  end
end
