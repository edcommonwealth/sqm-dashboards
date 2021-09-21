class AddResponseIdToSurveyItemResponses < ActiveRecord::Migration[5.0]
  def change
    add_column :survey_item_responses, :response_id, :string, null: false
  end
end
