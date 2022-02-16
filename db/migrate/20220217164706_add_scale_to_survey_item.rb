class AddScaleToSurveyItem < ActiveRecord::Migration[7.0]
  def change
    add_reference :survey_items, :scale, null: false, foreign_key: true
    remove_reference :survey_items, :measure, null: false, foreign_key: true
  end
end
