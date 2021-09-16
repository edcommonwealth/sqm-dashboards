class CreateSurveyItems < ActiveRecord::Migration[5.0]
  def change
    create_table :survey_items do |t|
      t.integer :construct_id
      t.string :prompt
    end

    add_foreign_key :survey_items, :constructs
  end
end
