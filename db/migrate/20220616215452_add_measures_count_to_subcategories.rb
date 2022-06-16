class AddMeasuresCountToSubcategories < ActiveRecord::Migration[7.0]
  def change
    add_column :subcategories, :measures_count, :integer
  end
end
