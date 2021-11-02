class AddTimestampsToSubcategories < ActiveRecord::Migration[6.1]
  def change
    now = Time.zone.now
    change_table :subcategories do |t|
      t.timestamps default: now
    end
    change_column_default :subcategories, :created_at, from: now, to: nil
    change_column_default :subcategories, :updated_at, from: now, to: nil
  end
end
