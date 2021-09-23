class AddIndexesToSurveyItems < ActiveRecord::Migration[5.0]
  def change
    add_index :survey_items, :survey_item_id
    add_index :survey_items, :measure_id
  end
end
