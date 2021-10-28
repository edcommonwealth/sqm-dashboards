class CreateAdminDataItem < ActiveRecord::Migration[6.1]
  def change
    create_table :admin_data_items do |t|
      t.integer :measure_id, null: false
      t.string :admin_data_item_id, null: false
      t.string :description
      t.timestamps
    end

    add_foreign_key :admin_data_items, :measures
  end
end
