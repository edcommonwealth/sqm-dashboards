class RemoveNullConstraintsFromMeasureBenchmarks < ActiveRecord::Migration[6.1]
  def up
    change_table :measures do |t|
      t.change :watch_low_benchmark, :float, null: true
      t.change :growth_low_benchmark, :float, null: true
      t.change :approval_low_benchmark, :float, null: true
      t.change :ideal_low_benchmark, :float, null: true
    end
  end

  def down
    change_table :measures do |t|
      t.change :watch_low_benchmark, :float, null: false
      t.change :growth_low_benchmark, :float, null: false
      t.change :approval_low_benchmark, :float, null: false
      t.change :ideal_low_benchmark, :float, null: false
    end
  end
end
