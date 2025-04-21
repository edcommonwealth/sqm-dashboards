class CreateParentLanguages < ActiveRecord::Migration[8.0]
  def change
    create_table :parent_languages do |t|
      t.references :parent, null: false, foreign_key: true
      t.references :language, null: false, foreign_key: true

      t.timestamps
    end

    add_index :parent_languages, %i[parent_id language_id]
  end
end
