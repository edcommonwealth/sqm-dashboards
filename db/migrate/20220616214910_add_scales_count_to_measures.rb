class AddScalesCountToMeasures < ActiveRecord::Migration[7.0]
  def change
    add_column :measures, :scales_count, :integer
  end
end
