class AddUniqueIndextoRespondent < ActiveRecord::Migration[7.0]
  def change
    add_index :respondents, %i[school_id academic_year_id], unique: true
  end
end
