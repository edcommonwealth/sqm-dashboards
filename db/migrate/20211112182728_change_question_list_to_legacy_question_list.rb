class ChangeQuestionListToLegacyQuestionList < ActiveRecord::Migration[6.1]
  def change
    rename_table :question_lists, :legacy_question_lists
  end
end
