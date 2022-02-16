class CreateScales < ActiveRecord::Migration[7.0]
  def change
    create_table :scales do |t|
      t.string :scale_id, index: { unique: true }, null: false
      t.references :measure, null: false, foreign_key: true

      t.timestamps
    end
  end
end
