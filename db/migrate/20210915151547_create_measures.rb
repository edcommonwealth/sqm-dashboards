class CreateMeasures < ActiveRecord::Migration[5.0]
  def change
    create_table :measures do |t|
      t.string :measure_id, null: false
      t.string :name
      t.float :watch_low_benchmark, null: false
      t.float :growth_low_benchmark, null: false
      t.float :approval_low_benchmark, null: false
      t.float :ideal_low_benchmark, null: false
    end
  end
end
