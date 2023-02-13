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

  desc 'seed only lowell'
  task seed_only_lowell: :environment do
    seeder = Seeder.new rules: [Rule::SeedOnlyLowell]

    seeder.seed_academic_years '2016-17', '2017-18', '2018-19', '2019-20', '2020-21', '2021-22', '2022-23'
    seeder.seed_districts_and_schools Rails.root.join('data', 'master_list_of_schools_and_districts.csv')
    seeder.seed_surveys Rails.root.join('data', 'master_list_of_schools_and_districts.csv')
    seeder.seed_respondents Rails.root.join('data', 'master_list_of_schools_and_districts.csv')
    seeder.seed_sqm_framework Rails.root.join('data', 'sqm_framework.csv')
    seeder.seed_demographics Rails.root.join('data', 'demographics.csv')
  end

  desc 'load survey responses for lowell schools'
  task load_survey_responses_for_lowell: :environment do
    survey_item_response_count = SurveyItemResponse.count
    student_count = Student.count
    path = '/data/survey_responses/clean/'
    Sftp::Directory.open(path:) do |file|
      SurveyResponsesDataLoader.from_file(file:)
    end
    puts "=====================> Completed loading #{SurveyItemResponse.count - survey_item_response_count} survey responses. #{SurveyItemResponse.count} total responses in the database"

    Sftp::Directory.open(path:) do |file|
      StudentLoader.from_file(file:, rules: [Rule::SkipNonLowellSchools])
    end
    puts "=====================> Completed loading #{Student.count - student_count} students. #{Student.count} total students"

    puts 'Resetting response rates'
    ResponseRateLoader.reset
    puts "=====================> Completed loading #{ResponseRate.count} response rates"

    puts 'Resetting race scores'
    RaceScoreLoader.reset(fast_processing: false)
    puts "=====================> Completed loading #{RaceScore.count} race scores"

    Rails.cache.clear
  end

  desc 'load students for lowell'
  task load_students_for_lowell: :environment do
    student_count = Student.count
    SurveyItemResponse.update_all(student_id: nil)
    StudentRace.delete_all
    Student.delete_all

    Sftp::Directory.open(path: '/data/survey_responses/clean/') do |file|
      StudentLoader.from_file(file:, rules: [Rule::SkipNonLowellSchools])
    end
    puts "=====================> Completed loading #{Student.count - student_count} students. #{Student.count} total students"

    puts 'Resetting race scores'
    RaceScoreLoader.reset(fast_processing: false)
    puts "=====================> Completed loading #{RaceScore.count} survey responses"

    Rails.cache.clear
  end

  desc 'delete non-lowell schools and districts'
  task delete_non_lowell: :environment do
    schools = School.all.reject { |s| s.district.name == 'Lowell' }
    ResponseRate.where(school: schools).delete_all
    Respondent.where(school: schools).delete_all
    Survey.where(school: schools).delete_all
    schools.each { |school| school.delete }
    districts = District.all.reject { |district| district.name == 'Lowell' }
    districts.each { |district| district.delete }
  end

  task load_survey_responses_21_22: :environment do
    Dir.glob(Rails.root.join('data', 'survey_responses', '*2021-22*.csv')).each do |filepath|
      puts "=====================> Loading data from csv at path: #{filepath}"
      SurveyResponsesDataLoader.load_data filepath:
    end
    puts "=====================> Completed loading #{SurveyItemResponse.count} survey responses"
  end

  task load_survey_responses_20_21: :environment do
    Dir.glob(Rails.root.join('data', 'survey_responses', '*2020-21*.csv')).each do |filepath|
      puts "=====================> Loading data from csv at path: #{filepath}"
      SurveyResponsesDataLoader.load_data filepath:
    end
    puts "=====================> Completed loading #{SurveyItemResponse.count} survey responses"
  end

  task load_survey_responses_19_20: :environment do
    Dir.glob(Rails.root.join('data', 'survey_responses', '*2019-20*.csv')).each do |filepath|
      puts "=====================> Loading data from csv at path: #{filepath}"
      SurveyResponsesDataLoader.load_data filepath:
    end
    puts "=====================> Completed loading #{SurveyItemResponse.count} survey responses"
  end

  task load_survey_responses_18_19: :environment do
    Dir.glob(Rails.root.join('data', 'survey_responses', '*2018-19*.csv')).each do |filepath|
      puts "=====================> Loading data from csv at path: #{filepath}"
      SurveyResponsesDataLoader.load_data filepath:
    end
    puts "=====================> Completed loading #{SurveyItemResponse.count} survey responses"
  end

  task load_survey_responses_17_18: :environment do
    Dir.glob(Rails.root.join('data', 'survey_responses', '*2017-18*.csv')).each do |filepath|
      puts "=====================> Loading data from csv at path: #{filepath}"
      SurveyResponsesDataLoader.load_data filepath:
    end
    puts "=====================> Completed loading #{SurveyItemResponse.count} survey responses"
  end

  task load_survey_responses_16_17: :environment do
    Dir.glob(Rails.root.join('data', 'survey_responses', '*2016-17*.csv')).each do |filepath|
      puts "=====================> Loading data from csv at path: #{filepath}"
      SurveyResponsesDataLoader.load_data filepath:
    end
    puts "=====================> Completed loading #{SurveyItemResponse.count} survey responses"
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

  desc 'scrape dese site for admin data'
  task scrape_all: :environment do
    puts 'scraping data from dese'
    scrapers = [Dese::OneAOne, Dese::OneAThree, Dese::TwoAOne, Dese::TwoCOne, Dese::ThreeAOne, Dese::ThreeATwo,
                Dese::ThreeBOne, Dese::ThreeBTwo, Dese::FourAOne, Dese::FourBTwo, Dese::FourDOne, Dese::FiveCOne, Dese::FiveDTwo]
    scrapers.each do |scraper|
      scraper.new.run_all
    end
  end
end
