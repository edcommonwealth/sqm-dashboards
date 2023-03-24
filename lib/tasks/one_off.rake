namespace :one_off do
  task add_dese_ids: :environment do
    all_schools = School.all.includes(:district)
    updated_schools = []

    qualtrics_schools = {}

    csv_file = Rails.root.join('data', 'master_list_of_schools_and_districts.csv')
    CSV.parse(File.read(csv_file), headers: true) do |row|
      district_id = row['District Code'].to_i
      school_id = row['School Code'].to_i

      if qualtrics_schools[[district_id, school_id]].present?
        puts "Duplicate entry row #{row}"
        next
      end

      qualtrics_schools[[district_id, school_id]] = row
    end

    qualtrics_schools.each do |(district_id, school_id), csv_row|
      school = all_schools.find do |school|
        school.qualtrics_code == school_id && school.district.qualtrics_code == district_id
      end

      if school.nil?
        school_name = csv_row['School Name'].strip
        puts "Could not find school '#{school_name}' with district id: #{district_id}, school id: #{school_id}"
        potential_school_ids = School.where('name like ?', "%#{school_name}%").map(&:id)
        puts "Potential ID matches: #{potential_school_ids}" if potential_school_ids.present?
        next
      end

      school.update!(dese_id: csv_row['DESE School ID'])
      updated_schools << school.id
    end

    School.where.not(id: updated_schools).each do |school|
      puts "School with unchanged DESE id: #{school.name}, id: #{school.id}"
    end
  end

  desc 'load a single file'
  task load_single_file: :environment do
    filepath = Rails.root.join('data', 'survey_responses',
                               '2021-22_revere_somerville_wareham_student_survey_responses.csv')
    puts "=====================> Loading data from csv at path: #{filepath}"
    SurveyResponsesDataLoader.load_data(filepath:)
    puts "=====================> Completed loading #{SurveyItemResponse.count} survey responses"
    puts 'Resetting response rates'
    ResponseRateLoader.reset
    puts "=====================> Completed recalculating #{ResponseRate.count} response rates"
  end

  desc 'load butler results for 2021-22'
  task load_butler: :environment do
    ['2022-23_butler_student_survey_responses.csv',
     '2022-23_butler_teacher_survey_responses.csv'].each do |filepath|
      filepath = Rails.root.join('data', 'survey_responses', filepath)
      puts "=====================> Loading data from csv at path: #{filepath}"
      SurveyResponsesDataLoader.load_data filepath:
    end
    puts 'Resetting response rates'
    ResponseRateLoader.reset
    puts "=====================> Completed recalculating #{ResponseRate.count} response rates"
  end

  desc 'load winchester results for 2021-22'
  task load_winchester: :environment do
    ['2021-22_winchester_student_survey_responses.csv',
     '2021-22_winchester_teacher_survey_responses.csv'].each do |filepath|
      filepath = Rails.root.join('data', 'survey_responses', filepath)
      puts "=====================> Loading data from csv at path: #{filepath}"
      SurveyResponsesDataLoader.load_data filepath:
    end
    puts 'Resetting response rates'
    ResponseRateLoader.reset
    puts "=====================> Completed recalculating #{ResponseRate.count} response rates"
  end

  desc 'load students'
  task load_students: :environment do
    Dir.glob(Rails.root.join('data', 'survey_responses', '2021-22_*student*.csv')).each do |file|
      puts "=====================> Loading student data from csv at path: #{file}"
      StudentLoader.load_data filepath: file
    end
    puts "=====================> Completed loading #{Student.count} survey responses"
  end

  desc 'reset race score calculations'
  task reset_race_scores_2021: :environment do
    puts 'Resetting race scores'
    academic_years = [AcademicYear.find_by_range('2021-22')]
    RaceScoreLoader.reset(academic_years:, fast_processing: true)
    Rails.cache.clear
    puts "=====================> Completed loading #{RaceScore.count} race scores"
  end

  desc 'list scales that have no survey responses'
  task list_scales_that_lack_survey_responses: :environment do
    output = AcademicYear.all.map do |academic_year|
      Scale.all.map do |scale|
        [academic_year.range, scale.scale_id, scale.survey_item_responses.where(academic_year:).count]
      end
    end

    output = output.map { |year| year.reject { |scale| scale[2] > 0 || scale[1].starts_with?('a-') } }
    pp output
  end

  desc 'list survey_items that have no survey responses by district'
  task list_survey_items_that_lack_responses: :environment do
    output = AcademicYear.all.map do |academic_year|
      District.all.map do |district|
        SurveyItem.all.map do |survey_item|
          [academic_year.range, survey_item.survey_item_id,
           survey_item.survey_item_responses.joins(:school).where("school.district": district, academic_year:).count, district.name]
        end
      end
    end

    output = output.map do |year|
      year.map do |district|
        district.reject do |survey_item|
          survey_item[2] > 0 || survey_item[1].starts_with?('a-')
        end
      end
    end
    pp output
  end

  desc 'list the most recent admin data values'
  task list_recent_admin_data_values: :environment do
    range = 4.weeks.ago..1.second.ago
    values = AdminDataValue.where(updated_at: range).group(:admin_data_item).count.map do |item|
      [item[0].admin_data_item_id, item[0].scale.measure.measure_id]
    end
    puts values
  end

  desc 'delete survey item responses for 2016-2018'
  task delete_survey_responses_2016_18: :environment do
    academic_years = AcademicYear.where(range: %w[2016-17 2017-18])
    response_count = SurveyItemResponse.where(academic_year: academic_years).count
    SurveyItemResponse.where(academic_year: academic_years).delete_all
    puts "Deleted #{response_count} survey item responses"
  end

  desc 'load survey responses for 2022-23'
  task load_survey_responses_2022_23: :environment do
    survey_item_response_count = SurveyItemResponse.count
    academic_year = AcademicYear.find_by_range '2022-23'
    academic_years = [academic_year]
    student_count = Student.count
    path = '/data/survey_responses/2022_23'
    Sftp::Directory.open(path:) do |file|
      SurveyResponsesDataLoader.from_file(file:)
    end
    puts "=====================> Completed loading #{SurveyItemResponse.count - survey_item_response_count} survey responses. #{SurveyItemResponse.count} total responses in the database"

    Sftp::Directory.open(path:) do |file|
      StudentLoader.from_file(file:, rules: [])
    end
    puts "=====================> Completed loading #{Student.count - student_count} students. #{Student.count} total students"

    puts 'Resetting response rates'
    ResponseRateLoader.reset(academic_years:)
    puts "=====================> Completed loading #{ResponseRate.count} response rates"

    puts 'Resetting race scores'
    RaceScoreLoader.reset(fast_processing: false, academic_years:)
    puts "=====================> Completed loading #{RaceScore.count} race scores"

    District.all.each do |district|
      num_of_respondents = SurveyItemResponse.joins(school: :district).where(academic_year:,
                                                                             "schools.district": district).pluck(:response_id).uniq.count
      teacher_respondents = SurveyItemResponse.joins(school: :district).where(academic_year:,
                                                                              survey_item: SurveyItem.where('survey_item_id like ? ', 't-%'), "schools.district": district).pluck(:response_id).uniq.count
      student_respondents = SurveyItemResponse.joins(school: :district).where(academic_year:,
                                                                              survey_item: SurveyItem.where('survey_item_id like ? ', 's-%'), "schools.district": district).pluck(:response_id).uniq.count

      response_count = SurveyItemResponse.joins(school: :district).where(academic_year:,
                                                                         "schools.district": district).count
      student_response_count = SurveyItemResponse.joins(school: :district).joins(:survey_item).where(academic_year:,
                                                                                                     survey_item: SurveyItem.where('survey_item_id like ? ', 's-%'), "schools.district": district).count
      teacher_response_count = SurveyItemResponse.joins(school: :district).joins(:survey_item).where(academic_year:,
                                                                                                     survey_item: SurveyItem.where('survey_item_id like ? ', 't-%'), "schools.district": district).count
      puts "#{district.name} has #{num_of_respondents} respondents"
      puts "#{district.name} has #{teacher_respondents} teacher respondents"
      puts "#{district.name} has #{student_respondents} student respondents"
      puts "#{district.name} has #{response_count} responses"
      puts "#{district.name} has #{student_response_count} teacher responses"
      puts "#{district.name} has #{teacher_response_count} student responses"
      puts "\n"
    end
    Rails.cache.clear
  end
end
