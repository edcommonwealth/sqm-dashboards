class CreateParentEmployment < ActiveRecord::Migration[8.0]
  def change
    create_table :parent_employments do |t|
      t.references :parent, null: false, foreign_key: true
      t.references :employment, null: false, foreign_key: true

      t.timestamps
    end
  end
end
