class AddForeignKeyFromMeasuresToSubcategories < ActiveRecord::Migration[5.0]
  def change
    add_column :measures, :subcategory_id, :integer, null: false

    add_foreign_key :measures, :subcategories
  end
end
