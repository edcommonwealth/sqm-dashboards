class AddSubcategoryIdToSubcategory < ActiveRecord::Migration[6.1]
  def change
    add_column :subcategories, :subcategory_id, :string, default: 'default-subcategory-id', null: false

    change_column_default :subcategories, :subcategory_id, from: 'default-subcategory-id', to: nil
  end
end
