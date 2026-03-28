namespace(:data) do
  # locally
  # bundle exec rake data:load_survey_responses

  # on heroku staging environment
  # heroku run:detached -a mciea-beta bundle exec rake data:load_survey_responses

  # on heroku production environment
  # heroku run:detached -a mciea-dashboard bundle exec rake data:load_survey_responses

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

  # Usage:
  # SFTP_PATH=/data/survey_responses/clean/2022_23 bundle exec rake data:load_survey_responses_from_path
  # You can also swap the order of the commands and environment variables
  # bundle exec rake data:load_survey_responses_from_path  SFTP_PATH=/ecp/data/survey_responses/clean/2024_25

  # on heroku staging environment
  # heroku run:detached -a mciea-beta SFTP_PATH=/ecp/data/survey_responses/clean/2024_25 bundle exec rake data:load_survey_responses_from_path

  # on heroku production environment
  # heroku run:detached -a mciea-dashboard SFTP_PATH=/ecp/data/survey_responses/clean/2024_25 bundle exec rake data:load_survey_responses_from_path

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

  # locally
  # $ bundle exec rake data:load_admin_data

  # on heroku staging environment
  # $ heroku run:detached -a mciea-beta bundle exec rake data:load_admin_data

  # on heroku production environment
  # $ heroku run:detached -a mciea-dashboard bundle exec rake data:load_admin_data

  desc("load admin_data")
  task(load_admin_data: :environment) do
    original_count = AdminDataValue.count
    pool_size = 2
    jobs = Queue.new
    Dir.glob(Rails.root.join("data", "admin_data", "dese", "*.csv")).each { |filepath| jobs << filepath }
    Dir.glob(Rails.root.join("data", "admin_data", "out_of_state", "*.csv")).each { |filepath| jobs << filepath }

    lee_pre_load = AdminDataValue.where(school: School.find_by_name("Lee Middle/High School")).group(:academic_year).count.sort_by { |ay, _count| ay.range }.map { |ay, count| [ay.range, count] }

    pre_count = AdminDataValue.order(:academic_year_id).group(:academic_year).count.map { |ay, count| [ay.range, count] }

    pre_values = AdminDataValue.all.pluck(:id)
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

    lee_post_load = AdminDataValue.where(school: School.find_by_name("Lee Middle/High School")).group(:academic_year).count.sort_by { |ay, _count| ay.range }.map { |ay, count| [ay.range, count] }

    puts "=====================> Lee Middle/High School admin data values by academic year before load: #{lee_pre_load}"
    puts "=====================> Lee Middle/High School admin data values by academic year after load: #{lee_post_load}"

    puts("=====================> Admin data items by academic year")

    post_count = AdminDataValue.order(:academic_year_id).group(:academic_year).count.map { |ay, count| [ay.range, count] }

    puts("=====================> Admin data values by academic year before load: #{pre_count}")
    puts("=====================> Admin data values by academic year after load: #{post_count}")
    post_values = AdminDataValue.all.pluck(:id)
    puts("======================> Loaded #{post_values.count - pre_values.count} new admin data value ids, #{post_values - pre_values} ")
    puts "======================> Admin Data Items that changed: #{(post_values - pre_values).map { |id| AdminDataValue.find(id) }.map { |value| [value.academic_year.range, value.admin_data_item.admin_data_item_id] }.uniq}"

    puts("=====================> Completed loading #{AdminDataValue.count - original_count} admin data values")

    Rails.cache.clear

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
