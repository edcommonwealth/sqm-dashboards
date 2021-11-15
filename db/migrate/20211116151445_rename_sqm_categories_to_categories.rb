class RenameSqmCategoriesToCategories < ActiveRecord::Migration[6.1]
  def change
    rename_table :sqm_categories, :categories
    rename_column :subcategories, :sqm_category_id, :category_id
  end
end
