class AddBenchmarksToSurveyItems < ActiveRecord::Migration[6.1]
  def change
    add_column :survey_items, :watch_low_benchmark, :float
    add_column :survey_items, :growth_low_benchmark, :float
    add_column :survey_items, :approval_low_benchmark, :float
    add_column :survey_items, :ideal_low_benchmark, :float
  end
end
