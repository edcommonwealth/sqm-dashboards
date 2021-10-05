class AddDescriptionToSqmCategory < ActiveRecord::Migration[5.1]
  def change
    add_column :sqm_categories, :description, :text
  end
end
