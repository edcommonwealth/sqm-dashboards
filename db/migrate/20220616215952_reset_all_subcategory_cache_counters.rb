class ResetAllSubcategoryCacheCounters < ActiveRecord::Migration[7.0]
  def up
    Subcategory.all.each do |subcategory|
      Subcategory.reset_counters(subcategory.id, :measures)
    end
  end

  def down; end
end
