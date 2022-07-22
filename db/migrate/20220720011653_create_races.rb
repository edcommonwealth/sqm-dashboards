class CreateRaces < ActiveRecord::Migration[7.0]
  def change
    create_table :races do |t|
      t.string :designation
      t.integer :qualtrics_code

      t.timestamps
    end
    add_index :races, :designation, unique: true
    add_index :races, :qualtrics_code, unique: true
  end
end
