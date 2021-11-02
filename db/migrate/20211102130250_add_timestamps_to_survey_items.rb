class AddTimestampsToSurveyItems < ActiveRecord::Migration[6.1]
  def change
    now = Time.zone.now
    change_table :survey_items do |t|
      t.timestamps default: now
    end
    change_column_default :survey_items, :created_at, from: now, to: nil
    change_column_default :survey_items, :updated_at, from: now, to: nil
  end
end
