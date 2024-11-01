class AddParentToSurveyItemResponse < ActiveRecord::Migration[7.1]
  def change
    add_reference :survey_item_responses, :parent, foreign_key: true
  end
end
