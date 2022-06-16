class ResetAllCategoryCacheCounters < ActiveRecord::Migration[7.0]
  def up
    Category.all.each do |category|
      Category.reset_counters(category.id, :subcategories)
    end
  end

  def down; end
end
