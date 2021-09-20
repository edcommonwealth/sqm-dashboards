class CreateSurveyItemResponses < ActiveRecord::Migration[5.0]
  def change
    create_table :survey_item_responses do |t|
      t.string :academic_year
      t.integer :likert_score
      t.integer :school_id, null: false
      t.integer :survey_item_id, null: false
    end

    add_foreign_key :survey_item_responses, :schools
    add_foreign_key :survey_item_responses, :survey_items
  end
end
