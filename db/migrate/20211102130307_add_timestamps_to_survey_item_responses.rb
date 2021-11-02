class AddTimestampsToSurveyItemResponses < ActiveRecord::Migration[6.1]
  def change
    now = Time.zone.now
    change_table :survey_item_responses do |t|
      t.timestamps default: now
    end
    change_column_default :survey_item_responses, :created_at, from: now, to: nil
    change_column_default :survey_item_responses, :updated_at, from: now, to: nil
  end
end
