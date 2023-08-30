class CreateEll < ActiveRecord::Migration[7.0]
  def change
    create_table :ells do |t|
      t.string :designation
      t.string :slug

      t.timestamps
    end

    add_index :ells, :designation, unique: true
  end
end
