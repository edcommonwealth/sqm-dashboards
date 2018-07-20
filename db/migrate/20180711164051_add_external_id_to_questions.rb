class AddExternalIdToQuestions < ActiveRecord::Migration[5.0]
  def change
    add_column :questions, :external_id, :string
    add_column :school_categories, :year, :string
  end
end

# SchoolCategory.update_all(year: '2017')
