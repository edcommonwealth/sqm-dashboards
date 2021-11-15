class CreateDistrictForNewDashboard < ActiveRecord::Migration[6.1]
  def change
    create_table :districts do |t|
      t.string :name
      t.string :slug
      t.integer :qualtrics_code

      t.timestamps
    end
  end
end
