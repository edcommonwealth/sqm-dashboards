class AddTimestampsToMeasures < ActiveRecord::Migration[6.1]
  def change
    now = Time.zone.now
    change_table :measures do |t|
      t.timestamps default: now
    end
    change_column_default :measures, :created_at, from: now, to: nil
    change_column_default :measures, :updated_at, from: now, to: nil
  end
end
