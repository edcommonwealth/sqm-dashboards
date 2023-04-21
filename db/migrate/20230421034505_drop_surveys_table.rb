class DropSurveysTable < ActiveRecord::Migration[7.0]
  def change
    drop_table :surveys do |t|
      t.integer :form
      t.references :academic_year, null: false, foreign_key: true
      t.references :school, null: false, foreign_key: true

      t.timestamps
    end
  end
end
