require 'csv'

class Seeder
  def seed_academic_years(*academic_year_ranges)
    academic_year_ranges.each do |range|
      AcademicYear.find_or_create_by! range:
    end
  end

  def seed_districts_and_schools(csv_file)
    dese_ids = []
    CSV.parse(File.read(csv_file), headers: true) do |row|
      district_name = row['District'].strip
      district_code = row['District Code'].try(:strip)
      dese_id = row['DESE School ID'].strip
      dese_ids << dese_id
      school_name = row['School Name'].strip
      school_code = row['School Code'].try(:strip)
      hs = row['HS?']

      district = District.find_or_create_by! name: district_name
      district.update! slug: district_name.parameterize, qualtrics_code: district_code

      school = School.find_or_initialize_by dese_id: dese_id, district: district
      school.name = school_name
      school.qualtrics_code = school_code
      school.is_hs = marked? hs
      school.save!
    end

    Respondent.joins(:school).where.not("school.dese_id": dese_ids).destroy_all
    Survey.joins(:school).where.not("school.dese_id": dese_ids).destroy_all
    School.where.not(dese_id: dese_ids).destroy_all
  end

  def seed_surveys(csv_file)
    CSV.parse(File.read(csv_file), headers: true) do |row|
      district_name = row['District'].strip
      district = District.find_or_create_by! name: district_name
      dese_id = row['DESE School ID'].strip
      school = School.find_or_initialize_by dese_id: dese_id, district: district
      academic_years = AcademicYear.all
      academic_years.each do |academic_year|
        short_form = row["Short Form Only (#{academic_year.range})"]
        survey = Survey.find_or_initialize_by(school:, academic_year:)
        is_short_form_school = marked?(short_form)
        survey.form = is_short_form_school ? Survey.forms[:short] : Survey.forms[:normal]
        survey.save!
      end
    end
  end

  def seed_respondents(csv_file)
    schools = []
    CSV.parse(File.read(csv_file), headers: true) do |row|
      dese_id = row['DESE School ID'].strip.to_i

      district_name = row['District'].strip
      district = District.find_or_create_by! name: district_name

      school = School.find_by dese_id: dese_id, district: district
      schools << school

      academic_years = AcademicYear.all
      academic_years.each do |academic_year|
        total_students = row["Total Students for Response Rate (#{academic_year.range})"]
        total_teachers = row["Total Teachers for Response Rate (#{academic_year.range})"]
        total_students = remove_commas(total_students)
        total_teachers = remove_commas(total_teachers)
        respondent = Respondent.find_or_initialize_by school: school, academic_year: academic_year
        respondent.total_students = total_students
        respondent.total_teachers = total_teachers
        respondent.academic_year = academic_year
        respondent.save
      end
    end

    Respondent.where.not(school: schools).destroy_all
  end

  def seed_sqm_framework(csv_file)
    CSV.parse(File.read(csv_file), headers: true) do |row|
      category_id = row['Category ID'].strip
      category = Category.find_or_create_by!(category_id:)
      category_slugs = {
        '1' => 'teachers-and-leadership',
        '2' => 'school-culture',
        '3' => 'resources',
        '4' => 'academic-learning',
        '5' => 'community-and-wellbeing'
      }
      category.update! name: row['Category'].strip, description: row['Category Description'].strip,
                       short_description: row['Category Short Description'], slug: category_slugs[category_id], sort_index: category_slugs.keys.index(category_id)

      subcategory_id = row['Subcategory ID'].strip
      subcategory = Subcategory.find_or_create_by! subcategory_id: subcategory_id, category: category
      subcategory.update! name: row['Subcategory'].strip, description: row['Subcategory Description'].strip

      measure_id = row['Measure ID'].strip
      measure_name = row['Measures'].try(:strip)
      watch_low = row['Item Watch Low'].try(:strip)
      growth_low = row['Item Growth Low'].try(:strip)
      approval_low = row['Item Approval Low'].try(:strip)
      ideal_low = row['Item Ideal Low'].try(:strip)
      on_short_form = row['On Short Form?'].try(:strip)
      measure_description = row['Measure Description'].try(:strip)

      next if row['Source'] == 'No source'

      measure = Measure.find_or_create_by! measure_id: measure_id, subcategory: subcategory
      measure.name = measure_name
      measure.description = measure_description
      measure.save!

      data_item_id = row['Survey Item ID'].strip
      scale_id = data_item_id.split('-')[0..1].join('-')
      scale = Scale.find_or_create_by! scale_id: scale_id, measure: measure

      if %w[Teachers Students].include? row['Source']
        survey_item = SurveyItem.where(survey_item_id: data_item_id, scale:).first_or_create
        survey_item.watch_low_benchmark = watch_low if watch_low
        survey_item.growth_low_benchmark = growth_low if growth_low
        survey_item.approval_low_benchmark = approval_low if approval_low
        survey_item.ideal_low_benchmark = ideal_low if ideal_low
        survey_item.on_short_form = marked? on_short_form
        survey_item.update! prompt: row['Question/item (20-21)'].strip
      end

      if row['Source'] == 'Admin Data'
        admin_data_item = AdminDataItem.where(admin_data_item_id: data_item_id, scale:).first_or_create
        admin_data_item.watch_low_benchmark = watch_low if watch_low
        admin_data_item.growth_low_benchmark = growth_low if growth_low
        admin_data_item.approval_low_benchmark = approval_low if approval_low
        admin_data_item.ideal_low_benchmark = ideal_low if ideal_low
        admin_data_item.description = row['Question/item (20-21)'].strip
        admin_data_item.hs_only_item = marked? row['HS only admin item?']
        admin_data_item.save!
      end
    end
  end

  private

  def marked?(mark)
    mark.present? ? mark.upcase.strip == 'X' : false
  end

  def remove_commas(target)
    target.gsub(',', '') if target.present?
  end
end
