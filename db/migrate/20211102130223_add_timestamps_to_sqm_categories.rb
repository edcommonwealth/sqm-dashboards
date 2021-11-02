class AddTimestampsToSqmCategories < ActiveRecord::Migration[6.1]
  def change
    now = Time.zone.now
    change_table :sqm_categories do |t|
      t.timestamps default: now
    end
    change_column_default :sqm_categories, :created_at, from: now, to: nil
    change_column_default :sqm_categories, :updated_at, from: now, to: nil
  end
end
