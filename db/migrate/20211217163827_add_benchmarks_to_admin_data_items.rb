class AddBenchmarksToAdminDataItems < ActiveRecord::Migration[6.1]
  def change
    add_column :admin_data_items, :watch_low_benchmark, :float
    add_column :admin_data_items, :growth_low_benchmark, :float
    add_column :admin_data_items, :approval_low_benchmark, :float
    add_column :admin_data_items, :ideal_low_benchmark, :float
  end
end
