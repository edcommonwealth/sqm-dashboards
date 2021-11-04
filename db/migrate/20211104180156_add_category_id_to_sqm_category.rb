class AddCategoryIdToSqmCategory < ActiveRecord::Migration[6.1]
  def change
    add_column :sqm_categories, :category_id, :string, default: 'default-category-id', null: false

    # give everything a default value
    change_column_default :sqm_categories, :category_id, from: 'default-category-id', to: nil
  end
end
