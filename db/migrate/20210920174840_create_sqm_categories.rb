class CreateSqmCategories < ActiveRecord::Migration[5.0]
  def change
    create_table :sqm_categories do |t|
      t.string :name
    end
  end
end
