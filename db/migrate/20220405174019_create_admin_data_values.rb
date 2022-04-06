class CreateAdminDataValues < ActiveRecord::Migration[7.0]
  def change
    create_table :admin_data_values do |t|
      t.float :likert_score
      t.references :school, null: false, foreign_key: true
      t.references :admin_data_item, null: false, foreign_key: true
      t.references :academic_year, null: false, foreign_key: true

      t.timestamps
    end
  end
end
