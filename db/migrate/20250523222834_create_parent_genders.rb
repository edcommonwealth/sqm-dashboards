class CreateParentGenders < ActiveRecord::Migration[8.0]
  def change
    create_table :parent_genders do |t|
      t.references :parent, null: false, foreign_key: true
      t.references :gender, null: false, foreign_key: true

      t.timestamps
    end
  end
end
