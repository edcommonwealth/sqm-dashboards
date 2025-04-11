class CreateHousings < ActiveRecord::Migration[8.0]
  def change
    create_table :housings do |t|
      t.string :designation
      t.string :slug

      t.timestamps
    end
  end
end
