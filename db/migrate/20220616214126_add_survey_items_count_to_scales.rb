class AddSurveyItemsCountToScales < ActiveRecord::Migration[7.0]
  def change
    add_column :scales, :survey_items_count, :integer
  end
end
