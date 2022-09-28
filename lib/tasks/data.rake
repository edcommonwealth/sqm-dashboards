require 'csv'

namespace :data do
  desc 'load survey responses'
  task load_survey_responses: :environment do
    Dir.glob(Rails.root.join('data', 'survey_responses', '*.csv')).each do |filepath|
      puts "=====================> Loading data from csv at path: #{filepath}"
      SurveyResponsesDataLoader.load_data filepath:
    end
    puts "=====================> Completed loading #{SurveyItemResponse.count} survey responses"

    puts 'Resetting response rates'
    ResponseRateLoader.reset
    puts "=====================> Completed loading #{ResponseRate.count} survey responses"

    puts 'Resetting race scores'
    RaceScoreLoader.reset(fast_processing: false)
    puts "=====================> Completed loading #{RaceScore.count} survey responses"

    Rails.cache.clear
  end

  desc 'reset response rate values'
  task reset_response_rates: :environment do
    puts 'Resetting response rates'
    ResponseRateLoader.reset
    Rails.cache.clear
    puts "=====================> Completed loading #{ResponseRate.count} survey responses"
  end

  desc 'reset race score calculations'
  task reset_race_scores: :environment do
    puts 'Resetting race scores'
    RaceScoreLoader.reset(fast_processing: false)
    Rails.cache.clear
    puts "=====================> Completed loading #{RaceScore.count} survey responses"
  end

  desc 'load admin_data'
  task load_admin_data: :environment do
    AdminDataValue.delete_all
    Dir.glob(Rails.root.join('data', 'admin_data', 'dese', '*.csv')).each do |filepath|
      puts "=====================> Loading data from csv at path: #{filepath}"
      Dese::Loader.load_data filepath:
    end
    puts "=====================> Completed loading #{AdminDataValue.count} survey responses"
  end

  desc 'load students'
  task load_students: :environment do
    SurveyItemResponse.update_all(student_id: nil)
    StudentRace.delete_all
    Student.delete_all
    Dir.glob(Rails.root.join('data', 'survey_responses', '*student*.csv')).each do |file|
      puts "=====================> Loading student data from csv at path: #{file}"
      StudentLoader.load_data filepath: file
    end
    puts "=====================> Completed loading #{Student.count} students"

    puts 'Resetting race scores'
    RaceScoreLoader.reset(fast_processing: false)
    puts "=====================> Completed loading #{RaceScore.count} survey responses"

    Rails.cache.clear
  end

  desc 'reset all cache counters'
  task reset_cache_counters: :environment do
    puts '=====================> Resetting Category counters'
    Category.all.each do |category|
      Category.reset_counters(category.id, :subcategories)
    end
    puts '=====================> Resetting Subcategory counters'
    Subcategory.all.each do |subcategory|
      Subcategory.reset_counters(subcategory.id, :measures)
    end
    puts '=====================> Resetting Measure counters'
    Measure.all.each do |measure|
      Measure.reset_counters(measure.id, :scales)
    end
    puts '=====================> Resetting Scale counters'
    Scale.all.each do |scale|
      Scale.reset_counters(scale.id, :survey_items)
    end
    puts '=====================> Resetting SurveyItem counters'
    SurveyItem.all.each do |survey_item|
      SurveyItem.reset_counters(survey_item.id, :survey_item_responses)
    end
  end
end
