class AddDescriptionToSubcategory < ActiveRecord::Migration[5.1]
  def change
    add_column :subcategories, :description, :text
  end
end
