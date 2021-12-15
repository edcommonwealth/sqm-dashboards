class RemoveBenchmarksFromMeasures < ActiveRecord::Migration[6.1]
  def change
    remove_column :measures, :watch_low_benchmark, :float
    remove_column :measures, :growth_low_benchmark, :float
    remove_column :measures, :approval_low_benchmark, :float
    remove_column :measures, :ideal_low_benchmark, :float
  end
end
