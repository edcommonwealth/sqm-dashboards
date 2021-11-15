class CreateSchoolForNewDashboard < ActiveRecord::Migration[6.1]
  def change
    create_table :schools do |t|
      t.string :name
      t.integer :district_id
      t.text :description
      t.string :slug
      t.integer :qualtrics_code

      t.timestamps
    end
  end
end
