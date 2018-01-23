class AddZScoreToSchoolCategories < ActiveRecord::Migration[5.0]
  def change
    add_column :school_categories, :zscore, :float
  end
end
