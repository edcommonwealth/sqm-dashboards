class AddScaleToAdminDataItem < ActiveRecord::Migration[7.0]
  def change
    add_reference :admin_data_items, :scale, null: false, foreign_key: true
    remove_reference :admin_data_items, :measure
    add_index :admin_data_items, :admin_data_item_id, unique: true
  end
end
