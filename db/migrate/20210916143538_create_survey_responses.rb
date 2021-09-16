class CreateSurveyResponses < ActiveRecord::Migration[5.0]
  def change
    create_table :survey_responses do |t|
      t.string :academic_year
      t.integer :likert_score
      t.integer :school_id
      t.integer :survey_item_id
    end

    add_foreign_key :survey_responses, :schools
    add_foreign_key :survey_responses, :survey_items
  end
end
