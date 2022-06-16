class AddSubcategoriesCountToCategories < ActiveRecord::Migration[7.0]
  def change
    add_column :categories, :subcategories_count, :integer
  end
end
