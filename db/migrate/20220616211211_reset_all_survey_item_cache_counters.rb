class ResetAllSurveyItemCacheCounters < ActiveRecord::Migration[7.0]
  def up
    SurveyItem.all.each do |survey_item|
      SurveyItem.reset_counters(survey_item.id, :survey_item_responses)
    end
  end

  def down; end
end
