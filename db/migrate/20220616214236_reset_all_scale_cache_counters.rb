class ResetAllScaleCacheCounters < ActiveRecord::Migration[7.0]
  def up
    Scale.all.each do |scale|
      Scale.reset_counters(scale.id, :survey_items)
    end
  end

  def down; end
end
