class CreateSpeds < ActiveRecord::Migration[7.0]
  def change
    create_table :speds do |t|
      t.string :designation
      t.string :slug

      t.timestamps
    end

    add_index :speds, :designation
  end
end
