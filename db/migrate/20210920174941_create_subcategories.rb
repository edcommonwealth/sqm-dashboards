class CreateSubcategories < ActiveRecord::Migration[5.0]
  def change
    create_table :subcategories do |t|
      t.string :name
      t.integer :sqm_category_id
    end

    add_foreign_key :subcategories, :sqm_categories
  end
end
