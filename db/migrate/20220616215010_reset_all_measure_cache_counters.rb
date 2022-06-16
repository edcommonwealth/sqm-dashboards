class ResetAllMeasureCacheCounters < ActiveRecord::Migration[7.0]
  def up
    Measure.all.each do |measure|
      Measure.reset_counters(measure.id, :scales)
    end
  end

  def down; end
end
