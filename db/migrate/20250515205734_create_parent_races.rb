class CreateParentRaces < ActiveRecord::Migration[8.0]
  def change
    create_table :parent_races do |t|
      t.references :parent, null: false, foreign_key: true
      t.references :race, null: false, foreign_key: true

      t.timestamps
    end
  end
end
