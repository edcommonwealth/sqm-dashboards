namespace(:data) do
  desc("load survey responses")
  task(load_survey_responses: :environment) do
    survey_item_response_count = SurveyItemResponse.count
    student_count = Student.count
    path = "/data/survey_responses/clean/"
    Sftp::Directory.open(path:) do |file|
      SurveyResponsesDataLoader.new.from_file(file:)
    end

    puts(
      "=====================> Completed loading #{SurveyItemResponse.count - survey_item_response_count} survey responses. #{SurveyItemResponse.count} total responses in the database"
    )

    Rails.cache.clear
  end

  desc("load survey responses from a specific directory")
  task(load_survey_responses_from_path: :environment) do
    survey_item_response_count = SurveyItemResponse.count
    student_count = Student.count
    path = "#{ENV["SFTP_PATH"]}"
    Sftp::Directory.open(path:) do |file|
      SurveyResponsesDataLoader.new.from_file(file:)
    end

    puts(
      "=====================> Completed loading #{SurveyItemResponse.count - survey_item_response_count} survey responses. #{SurveyItemResponse.count} total responses in the database"
    )

    Rails.cache.clear
  end

  desc("load admin_data")
  task(load_admin_data: :environment) do
    original_count = AdminDataValue.count
    pool_size = 2
    jobs = Queue.new
    Dir.glob(Rails.root.join("data", "admin_data", "dese", "*.csv")).each { |filepath| jobs << filepath }
    Dir.glob(Rails.root.join("data", "admin_data", "out_of_state", "*.csv")).each { |filepath| jobs << filepath }

    workers = pool_size.times.map do
      Thread.new do

        while filepath = jobs.pop(true)
          puts("=====================> Loading data from csv at path: #{filepath}")
          Dese::Loader.load_data(filepath:)
        end

      rescue ThreadError
      end
    end

    workers.each(&:join)

    puts("=====================> Completed loading #{AdminDataValue.count - original_count} admin data values")
  end

  desc("reset all cache counters")
  task(reset_cache_counters: :environment) do
    puts("=====================> Resetting Category counters")
    Category.all.each do |category|
      Category.reset_counters(category.id, :subcategories)
    end

    puts("=====================> Resetting Subcategory counters")
    Subcategory.all.each do |subcategory|
      Subcategory.reset_counters(subcategory.id, :measures)
    end

    puts("=====================> Resetting Measure counters")
    Measure.all.each do |measure|
      Measure.reset_counters(measure.id, :scales)
    end

    puts("=====================> Resetting Scale counters")
    Scale.all.each do |scale|
      Scale.reset_counters(scale.id, :survey_items)
    end

    puts("=====================> Resetting SurveyItem counters")
    SurveyItem.all.each do |survey_item|
      SurveyItem.reset_counters(survey_item.id, :survey_item_responses)
    end
  end
end
