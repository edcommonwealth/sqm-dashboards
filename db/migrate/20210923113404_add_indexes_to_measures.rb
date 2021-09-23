class AddIndexesToMeasures < ActiveRecord::Migration[5.0]
  def change
    add_index :measures, :measure_id
    add_index :measures, :subcategory_id
  end
end
