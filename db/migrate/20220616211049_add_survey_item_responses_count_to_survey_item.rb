class AddSurveyItemResponsesCountToSurveyItem < ActiveRecord::Migration[7.0]
  def change
    add_column :survey_items, :survey_item_responses_count, :integer
  end
end
