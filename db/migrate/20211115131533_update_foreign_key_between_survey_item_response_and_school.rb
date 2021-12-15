class UpdateForeignKeyBetweenSurveyItemResponseAndSchool < ActiveRecord::Migration[6.1]
  def change
    ActiveRecord::Base.connection.execute('DELETE FROM survey_item_responses')

    remove_foreign_key :survey_item_responses, :legacy_schools, column: :school_id
    add_foreign_key :survey_item_responses, :schools
  end
end
