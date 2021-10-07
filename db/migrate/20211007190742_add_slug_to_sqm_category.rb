class AddSlugToSqmCategory < ActiveRecord::Migration[5.1]
  def change
    add_column :sqm_categories, :slug, :string
    add_index :sqm_categories, :slug, unique: true
  end
end
