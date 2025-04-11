class CreateLanguages < ActiveRecord::Migration[8.0]
  def change
    create_table :languages do |t|
      t.string :designation
      t.string :slug

      t.timestamps
    end
  end
end
