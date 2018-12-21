class AddResponseTotalToSchoolQuestions < ActiveRecord::Migration[5.0]
  def change
    add_column :school_questions, :response_total, :integer
  end
end
