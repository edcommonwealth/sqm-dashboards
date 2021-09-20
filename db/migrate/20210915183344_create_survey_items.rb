class CreateSurveyItems < ActiveRecord::Migration[5.0]
  def change
    create_table :survey_items do |t|
      t.integer :measure_id, null: false
      t.string :survey_item_id, null: false
      t.string :prompt
    end

    add_foreign_key :survey_items, :measures
  end
end
