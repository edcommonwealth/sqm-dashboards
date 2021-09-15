class CreateConstructs < ActiveRecord::Migration[5.0]
  def change
    create_table :constructs do |t|
      t.string :construct_id
      t.string :name
      t.float :watch_low_benchmark
      t.float :growth_low_benchmark
      t.float :approval_low_benchmark
      t.float :ideal_low_benchmark
    end
  end
end
