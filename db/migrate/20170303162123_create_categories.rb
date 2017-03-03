class CreateCategories < ActiveRecord::Migration[5.0]
  def change
    create_table :categories do |t|
      t.string :name
      t.string :blurb
      t.text :description
      t.string :external_id
      t.integer :parent_category_id

      t.timestamps
    end
  end
end
