class RemoveUnneededIndexes < ActiveRecord::Migration[7.1]
  def change
    remove_index :response_rates, name: "index_response_rates_on_school_id", column: :school_id
    remove_index :student_races, name: "index_student_races_on_student_id", column: :student_id
    remove_index :survey_item_responses, name: "index_survey_item_responses_on_school_id", column: :school_id
    remove_index :survey_item_responses, name: "index_survey_item_responses_on_school_id_and_academic_year_id",
                                         column: %i[school_id academic_year_id]
  end
end
