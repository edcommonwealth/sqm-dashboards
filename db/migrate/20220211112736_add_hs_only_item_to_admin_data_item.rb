class AddHsOnlyItemToAdminDataItem < ActiveRecord::Migration[7.0]
  def change
    add_column :admin_data_items, :hs_only_item, :boolean, default: false
  end
end
