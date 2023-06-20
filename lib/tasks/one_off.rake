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

  desc 'load stoklosa results for 2022-23'
  task load_stoklosa: :environment do
    survey_item_response_count = SurveyItemResponse.count
    school = School.find_by_dese_id(1_600_360)
    academic_year = AcademicYear.find_by_range('2022-23')

    ['2022-23_stoklosa_student_survey_responses.csv',
     '2022-23_stoklosa_teacher_survey_responses.csv'].each do |filepath|
      filepath = Rails.root.join('data', 'survey_responses', filepath)
      puts "=====================> Loading data from csv at path: #{filepath}"
      SurveyResponsesDataLoader.load_data filepath:
    end
    puts "=====================> Completed loading #{SurveyItemResponse.count - survey_item_response_count} survey responses. #{SurveyItemResponse.count} total responses in the database"

    puts 'Resetting response rates'
    ResponseRateLoader.reset(schools: [school],
                             academic_years: [academic_year])

    Dir.glob(Rails.root.join('data', 'survey_responses',
                             '2022-23_stoklosa_student_survey_responses.csv')).each do |file|
      puts "=====================> Loading student data from csv at path: #{file}"
      StudentLoader.load_data filepath: file, rules: [Rule::SkipNonLowellSchools]
    end
    puts 'Resetting race scores'
    RaceScoreLoader.reset(fast_processing: true, schools: [school], academic_years: [academic_year])
    puts "=====================> Completed recalculating #{ResponseRate.count} response rates"
  end

  desc 'load butler results for 2022-23'
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

  desc 'load survey responses for lowell schools'
  task load_survey_responses_for_lowell: :environment do
    survey_item_response_count = SurveyItemResponse.count
    student_count = Student.count
    Sftp::Directory.open(path: '/test/survey_responses/') do |file|
      SurveyResponsesDataLoader.from_file(file:)
    end
    puts "=====================> Completed loading #{SurveyItemResponse.count - survey_item_response_count} survey responses. #{SurveyItemResponse.count} total responses in the database"

    Sftp::Directory.open(path: '/test/survey_responses/') do |file|
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

  desc 'delete 2022-23 survey responses'
  task delete_survey_responses_2022_23: :environment do
    response_count = SurveyItemResponse.all.count
    SurveyItemResponse.where(academic_year: AcademicYear.find_by_range('2022-23')).delete_all

    puts "=====================> Deleted #{response_count - SurveyItemResponse.all.count} survey responses"
    # should be somewhere near 295738
  end

  desc 'load survey responses'
  task load_survey_responses: :environment do
    survey_item_response_count = SurveyItemResponse.count
    student_count = Student.count
    path = '/data/survey_responses/clean/'
    schools = District.find_by_slug('maynard-public-schools').schools

    Sftp::Directory.open(path:) do |file|
      SurveyResponsesDataLoader.from_file(file:)
    end
    puts "=====================> Completed loading #{SurveyItemResponse.count - survey_item_response_count} survey responses. #{SurveyItemResponse.count} total responses in the database"

    Sftp::Directory.open(path:) do |file|
      StudentLoader.from_file(file:, rules: [])
    end
    puts "=====================> Completed loading #{Student.count - student_count} students. #{Student.count} total students"

    puts 'Resetting race scores'
    RaceScoreLoader.reset(fast_processing: false, academic_years: [AcademicYear.find_by_range('2022-23')], schools:)
    puts "=====================> Completed loading #{RaceScore.count} race scores"

    Rails.cache.clear
  end

  desc 'set response rates for lee schools to 100'
  task set_response_rates_for_lee: :environment do
    lee = District.find_by(name: 'Lee Public Schools')
    academic_year = AcademicYear.find_by_range('2022-23')
    sufficient_response_rate = ResponseRate.where(academic_year:, school: lee.schools).select do |rate|
      rate.student_response_rate > 0
    end.map(&:id)
    sufficient_response_rate = ResponseRate.where(id: sufficient_response_rate)
    sufficient_response_rate.update_all(student_response_rate: 100, meets_student_threshold: true)

    sufficient_response_rate = ResponseRate.where(academic_year:, school: lee.schools).select do |rate|
      rate.teacher_response_rate > 0
    end.map(&:id)
    sufficient_response_rate = ResponseRate.where(id: sufficient_response_rate)
    sufficient_response_rate.update_all(teacher_response_rate: 100, meets_teacher_threshold: true)
  end
  desc "Generate CSV report of teacher survey item responses"
  task teacher_survey_questions_csv: :environment do
    headers = ['School ID', 'Academic Year', 'Survey Item', 'Count','Percentage_diff']
    output_rows = []
    counts={}
    avg=0
    School.all.each do |sc|
      AcademicYear.all.each do |ay|
        sum=0
        nof_si=0
        threshold = Respondent.where(school: sc, academic_year: ay).pluck(:total_teachers)
        SurveyItem.teacher_survey_items.all.each do |si|
          c = SurveyItemResponse.where(school: sc, academic_year: ay, survey_item: si).group(:school_id).count
          if c.any? && (c.values.first >= 10 || c.values.first > threshold/4)
            counts[[sc.id, ay.id, si.id]] = c
            sum+=c.values.first
            nof_si+=1
          end
        end


          avg = sum.to_f/ nof_si
        counts.each do |key, value|
          if key[0] == sc.id && key[1] == ay.id
            count = value.values.first
            percentage_diff = ((count-avg) / avg) * 100
            counts[key] = { count: count, percentage_diff: percentage_diff }
        end
      end
    end  end

    counts.each do |key, value|
      output_rows << [School.where(id:key[0]).pluck(:name) , AcademicYear.where(id:key[1]).pluck(:range) , SurveyItem.where(id:key[2]).pluck(:survey_item_id), SurveyItem.where(id:key[2]).pluck(:prompt), value[:count], value[:percentage_diff]]
    end

    file = File.new('teacher_survey_questions.csv', 'w')
    CSV.open(file, 'w', write_headers: true, headers: headers) do |csv|
      output_rows.each do |row|
        csv << row
      end
    end

    file.close
    puts "CSV report of teacher survey item responses with removed stray responses.csv"
  end


  desc "Generate CSV report of short survey item responses"
  task short_survey_questions_csv: :environment do
    headers = ['School ID', 'Academic Year', 'Survey Item', 'Count','Percentage_diff']
    output_rows = []
    counts={}
    avg=0
    temp=0
    count_response_grades_not_in_grades=0
    School.all.each do |sc|
      if Respondent.where(school: sc).any?
      grades_count=Respondent.where(school:sc).first.counts_by_grade
      grades= grades_count.keys
      AcademicYear.all.each do |ay|
        sum=0
        nof_si=0
        threshold=0
        threshold = Respondent.where(school: sc, academic_year: ay).pluck(:total_students)
        SurveyItem.short_form_items.all.each do |si|
          c = SurveyItemResponse.where(school: sc, academic_year: ay, survey_item: si).group(:school_id).count
          response_grades = SurveyItemResponse.where(school: sc, academic_year: ay, survey_item: si).pluck(:grade)
          count_response_grades_not_in_grades = response_grades.count { |grade| !grades.include?(grade) }
           if !count_response_grades_not_in_grades.nil? && c.any?
            c[c.keys.first] = c.values.first - count_response_grades_not_in_grades
          end

           if threshold.any?
          if c.any? && (c.values.first >= 10 || c.values.first > threshold.first/4)
            counts[[sc.id, ay.id, si.id]] = c
            sum+=c.values.first
            nof_si+=1
          end
        end
        end


          avg = sum.to_f/ nof_si
        counts.each do |key, value|
          if key[0] == sc.id && key[1] == ay.id
            count = value.values.first
            percentage_diff = ((count-avg) / avg) * 100
            counts[key] = { count: count, percentage_diff: percentage_diff }
        end
      end
    end  end end

    counts.each do |key, value|
      output_rows << [School.where(id:key[0]).pluck(:name) , AcademicYear.where(id:key[1]).pluck(:range) , SurveyItem.where(id:key[2]).pluck(:survey_item_id), SurveyItem.where(id:key[2]).pluck(:prompt), value[:count], value[:percentage_diff]]
    end

    file = File.new('short_survey_questions.csv', 'w')
    CSV.open(file, 'w', write_headers: true, headers: headers) do |csv|
      output_rows.each do |row|
        csv << row
      end
    end

    file.close
    puts "CSV report of short survey item responses with removed stray responses.csv"
  end


    desc "Generate CSV report of early_education_surveysitem responses"
  task early_education_survey_questions_csv: :environment do
    headers = ['School ID', 'Academic Year', 'Survey Item', 'Count','Percentage_diff']
    output_rows = []
    counts={}
    avg=0
    temp=0
    count_response_grades_not_in_grades=0
    School.all.each do |sc|
      if Respondent.where(school: sc).any?
      grades_count=Respondent.where(school:sc).first.counts_by_grade
      grades= grades_count.keys
      AcademicYear.all.each do |ay|
        sum=0
        nof_si=0
        threshold=0
        threshold = Respondent.where(school: sc, academic_year: ay).pluck(:total_students)
        SurveyItem.early_education_surveys.all.each do |si|
          c = SurveyItemResponse.where(school: sc, academic_year: ay, survey_item: si).group(:school_id).count
          response_grades = SurveyItemResponse.where(school: sc, academic_year: ay, survey_item: si).pluck(:grade)
          count_response_grades_not_in_grades = response_grades.count { |grade| !grades.include?(grade) }
           if !count_response_grades_not_in_grades.nil? && c.any?
            c[c.keys.first] = c.values.first - count_response_grades_not_in_grades
          end

           if threshold.any?
          if c.any? && (c.values.first >= 10 || c.values.first > threshold.first/4)
            counts[[sc.id, ay.id, si.id]] = c
            sum+=c.values.first
            nof_si+=1
          end
        end
        end


          avg = sum.to_f/ nof_si
        counts.each do |key, value|
          if key[0] == sc.id && key[1] == ay.id
            count = value.values.first
            percentage_diff = ((count-avg) / avg) * 100
            counts[key] = { count: count, percentage_diff: percentage_diff }
        end
      end
    end  end end

    counts.each do |key, value|
      output_rows << [School.where(id:key[0]).pluck(:name) , AcademicYear.where(id:key[1]).pluck(:range) , SurveyItem.where(id:key[2]).pluck(:survey_item_id), SurveyItem.where(id:key[2]).pluck(:prompt), value[:count], value[:percentage_diff]]
    end

    file = File.new('early_education_surveys_questions.csv', 'w')
    CSV.open(file, 'w', write_headers: true, headers: headers) do |csv|
      output_rows.each do |row|
        csv << row
      end
    end

    file.close
    puts "CSV report of early_education_surveys items with removed stray responses.csv"
  end


  desc "Generate CSV report of survey item responses"
  task stray_responses: :environment do

    headers = ['School ID', 'Academic Year', 'Survey Item', 'Count','SurveyItemResponse ids']


    output_rows = []
    sir_ids=[]


      School.all.each do |sc|
      AcademicYear.all.each do |ay|
        SurveyItem.all.each do |si|
          count = SurveyItemResponse.where(school: sc, academic_year: ay, survey_item: si).count
          sir_ids= SurveyItemResponse.where(school: sc, academic_year: ay, survey_item: si).pluck(:response_id)

          if count > 0 && count < 10

            output_rows << [sc.name, ay.range, si.survey_item_id, count,sir_ids]
          end
        end
      end
    end


    file = File.new('stray_responses.csv', 'w')

    CSV.open(file, 'w', write_headers: true, headers: headers) do |csv|
      output_rows.each do |row|
        csv << row
      end
    end


    file.close

    puts "CSV report of survey item responses created in stray_responses.csv"
  end
end
