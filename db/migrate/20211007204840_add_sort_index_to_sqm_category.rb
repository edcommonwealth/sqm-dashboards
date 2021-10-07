class AddSortIndexToSqmCategory < ActiveRecord::Migration[5.1]
  def change
    add_column :sqm_categories, :sort_index, :integer
  end
end
