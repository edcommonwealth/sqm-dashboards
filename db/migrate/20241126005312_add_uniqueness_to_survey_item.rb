class AddUniquenessToSurveyItem < ActiveRecord::Migration[8.0]
  def change
    remove_index :survey_items, :survey_item_id
    add_index :survey_items, :survey_item_id, unique: true
  end
end
