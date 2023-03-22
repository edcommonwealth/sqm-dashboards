class RemoveSchoolIndexFromRespondents < ActiveRecord::Migration[7.0]
  def change
    remove_index :respondents, name: 'index_respondents_on_school_id'
  end
end
