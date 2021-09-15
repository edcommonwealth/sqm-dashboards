class CreateItems < ActiveRecord::Migration[5.0]
  def change
    create_table :items do |t|
      t.integer :construct_id
      t.string :prompt
    end

    add_foreign_key :items, :constructs
  end
end
