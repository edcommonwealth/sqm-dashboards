class AddOnShortFormToSurveyItem < ActiveRecord::Migration[7.0]
  def change
    add_column :survey_items, :on_short_form, :boolean, default: false
  end
end
