namespace :data do
  desc "load survey responses"
  task load_survey_responses: :environment do
    survey_item_response_count = SurveyItemResponse.count
    student_count = Student.count
    path = "/data/survey_responses/clean/"
    Sftp::Directory.open(path:) do |file|
      SurveyResponsesDataLoader.from_file(file:)
    end
    puts "=====================> Completed loading #{SurveyItemResponse.count - survey_item_response_count} survey responses. #{SurveyItemResponse.count} total responses in the database"

    Sftp::Directory.open(path:) do |file|
      StudentLoader.from_file(file:, rules: [])
    end
    puts "=====================> Completed loading #{Student.count - student_count} students. #{Student.count} total students"

    Rails.cache.clear
  end

  desc "load admin_data"
  task load_admin_data: :environment do
    original_count = AdminDataValue.count
    Dir.glob(Rails.root.join("data", "admin_data", "dese", "*.csv")).each do |filepath|
      puts "=====================> Loading data from csv at path: #{filepath}"
      Dese::Loader.load_data filepath:
    end

    Dir.glob(Rails.root.join("data", "admin_data", "out_of_state", "*.csv")).each do |filepath|
      puts "=====================> Loading data from csv at path: #{filepath}"
      Dese::Loader.load_data filepath:
    end
    puts "=====================> Completed loading #{AdminDataValue.count - original_count} admin data values"
  end

  desc "load students"
  task load_students: :environment do
    SurveyItemResponse.update_all(student_id: nil)
    StudentRace.delete_all
    Student.delete_all
    Dir.glob(Rails.root.join("data", "survey_responses", "*student*.csv")).each do |file|
      puts "=====================> Loading student data from csv at path: #{file}"
      StudentLoader.load_data filepath: file
    end
    puts "=====================> Completed loading #{Student.count} students"

    Rails.cache.clear
  end

  desc "reset all cache counters"
  task reset_cache_counters: :environment do
    puts "=====================> Resetting Category counters"
    Category.all.each do |category|
      Category.reset_counters(category.id, :subcategories)
    end
    puts "=====================> Resetting Subcategory counters"
    Subcategory.all.each do |subcategory|
      Subcategory.reset_counters(subcategory.id, :measures)
    end
    puts "=====================> Resetting Measure counters"
    Measure.all.each do |measure|
      Measure.reset_counters(measure.id, :scales)
    end
    puts "=====================> Resetting Scale counters"
    Scale.all.each do |scale|
      Scale.reset_counters(scale.id, :survey_items)
    end
    puts "=====================> Resetting SurveyItem counters"
    SurveyItem.all.each do |survey_item|
      SurveyItem.reset_counters(survey_item.id, :survey_item_responses)
    end
  end
end
