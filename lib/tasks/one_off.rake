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

  desc 'load boston 2018-19 responses'
  task load_boston_2018_19_responses: :environment do
    filepath = Rails.root.join('data', 'survey_responses', '2018-19_boston_student_survey_responses.csv')
    puts "=====================> Loading data from csv at path: #{filepath}"
    SurveyResponsesDataLoader.load_data filepath: filepath
    puts "=====================> Completed loading #{SurveyItemResponse.count} survey responses"
  end
end
