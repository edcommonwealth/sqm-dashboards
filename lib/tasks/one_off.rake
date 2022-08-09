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

  task change_overall_performance_measure_id: :environment do
    measure_4aii = Measure.where(name: 'Overall Performance')[0]
    measure_4aii.update! measure_id: '4A-i'
  end

  desc 'load a single file'
  task load_single_file: :environment do
    filepath = Rails.root.join('data', 'survey_responses', '2016-17_student_survey_responses.csv')
    puts "=====================> Loading data from csv at path: #{filepath}"
    SurveyResponsesDataLoader.load_data filepath: filepath
    puts "=====================> Completed loading #{SurveyItemResponse.count} survey responses"
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
  desc 'load revere somerville warehame results for 2021-22'
  task load_revere: :environment do
    ['2021-22_revere_somerville_wareham_student_survey_responses.csv',
     '2021-22_revere_somerville_wareham_teacher_survey_responses.csv'].each do |filepath|
      filepath = Rails.root.join('data', 'survey_responses', filepath)
      puts "=====================> Loading data from csv at path: #{filepath}"
      SurveyResponsesDataLoader.load_data filepath:
    end
    puts 'Resetting response rates'
    revere = District.find_by_name 'Revere'
    somerville = District.find_by_name 'Somerville'
    wareham = District.find_by_name 'Wareham'
    academic_year = AcademicYear.find_by_range '2021-22'
    ResponseRateLoader.reset(schools: revere.schools, academic_years: [academic_year])
    ResponseRateLoader.reset(schools: somerville.schools, academic_years: [academic_year])
    ResponseRateLoader.reset(schools: wareham.schools, academic_years: [academic_year])
    Rails.cache.clear
    puts "=====================> Completed recalculating #{ResponseRate.count} response rates"
  end

  desc 'load lowell and milford results for 2021-22'
  task load_lowell: :environment do
    ['2021-22_lowell_milford_student_survey_responses.csv',
     '2021-22_lowell_milford_teacher_survey_responses.csv'].each do |filepath|
      filepath = Rails.root.join('data', 'survey_responses', filepath)
      puts "=====================> Loading data from csv at path: #{filepath}"
      SurveyResponsesDataLoader.load_data filepath:
    end
    puts 'Resetting response rates'
    lowell = District.find_by_name 'Lowell'
    milford = District.find_by_name 'Milford'
    academic_year = AcademicYear.find_by_range '2021-22'
    ResponseRateLoader.reset(schools: lowell.schools, academic_years: [academic_year])
    ResponseRateLoader.reset(schools: milford.schools, academic_years: [academic_year])
    Rails.cache.clear
    puts "=====================> Completed recalculating #{ResponseRate.count} response rates"
  end

  desc 'reset race score calculations'
  task reset_race_scores: :environment do
    puts 'Resetting race scores'
    RaceScoreLoader.reset(academic_years: [AcademicYear.find_by_range('2021-22')])
    Rails.cache.clear
    puts "=====================> Completed loading #{RaceScore.count} survey responses"
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

  desc 'delete invalid scale'
  task delete_s_grmi_scale_from_2016_17: :environment do
    academic_year = AcademicYear.find_by_range '2016-17'
    survey_items = SurveyItem.where('survey_item_id LIKE ?', 's-grmi%')
    SurveyItemResponse.joins(:survey_item).where(academic_year:, survey_item: survey_items).delete_all
  end

  desc 'reset admin data values'
  task reset_admin_data_values: :environment do
    puts "Initial count of admin data values #{AdminDataValue.all.count}"
    AdminDataValue.delete_all
    puts 'Deleted all admin data values'

    Dir.glob(Rails.root.join('data', 'admin_data', '*.csv')).each do |filepath|
      puts "=====================> Loading data from csv at path: #{filepath}"
      AdminDataLoader.load_data filepath:
    end
    puts "=====================> Completed loading #{AdminDataValue.count} survey responses"
  end
end
