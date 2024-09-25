class Seeder
  attr_reader :rules

  def initialize(rules: [])
    @rules = rules
  end

  def seed_academic_years(*academic_year_ranges)
    academic_years = []
    academic_year_ranges.each do |range|
      academic_year = AcademicYear.find_or_initialize_by(range:)
      academic_years << academic_year
    end

    AcademicYear.import academic_years, on_duplicate_key_update: :all
  end

  def seed_districts_and_schools(csv_file)
    dese_ids = []
    schools = []
    CSV.parse(File.read(csv_file), headers: true) do |row|
      district_name = row["District"].strip
      next if rules.any? do |rule|
                rule.new(row:).skip_row?
              end

      district_code = row["District Code"].try(:strip)
      dese_id = row["DESE School ID"].strip
      dese_ids << dese_id
      school_name = row["School Name"].strip
      school_code = row["School Code"].try(:strip)
      hs = row["HS?"]

      district = District.find_or_create_by! name: district_name
      district.slug = district_name.parameterize
      district.qualtrics_code = district_code
      district.save

      school = School.find_or_initialize_by(dese_id:, district:)
      school.name = school_name
      school.qualtrics_code = school_code
      school.is_hs = marked? hs
      schools << school
    end

    School.import schools, on_duplicate_key_update: :all

    Respondent.joins(:school).where.not("school.dese_id": dese_ids).destroy_all
    School.where.not(dese_id: dese_ids).destroy_all
  end

  def seed_sqm_framework(csv_file)
    admin_data_item_ids = []
    CSV.parse(File.read(csv_file), headers: true) do |row|
      next if row["Source"] == "No source"

      category_id = row["Category ID"]&.strip

      category = Category.find_or_create_by!(category_id:)
      category_slugs = {
        "1" => "teachers-and-leadership",
        "2" => "school-culture",
        "3" => "resources",
        "4" => "academic-learning",
        "5" => "community-and-wellbeing"
      }
      category.update! name: row["Category"].strip, description: row["Category Description"].strip,
                       short_description: row["Category Short Description"], slug: category_slugs[category_id], sort_index: category_slugs.keys.index(category_id)

      subcategory_id = row["Subcategory ID"].strip
      subcategory = Subcategory.find_or_create_by!(subcategory_id:, category:)
      subcategory.update! name: row["Subcategory"].strip, description: row["Subcategory Description"].strip

      measure_id = row["Measure ID"]&.strip

      measure_name = row["Measures"].try(:strip)
      watch_low = row["Item Watch Low"].try(:strip)
      growth_low = row["Item Growth Low"].try(:strip)
      approval_low = row["Item Approval Low"].try(:strip)
      ideal_low = row["Item Ideal Low"].try(:strip)
      on_short_form = row["On Short Form?"].try(:strip)
      measure_description = row["Measure Description"].try(:strip)

      measure = Measure.find_or_create_by!(measure_id:, subcategory:)
      measure.name = measure_name
      measure.description = measure_description
      measure.save!

      data_item_id = row["Survey Item ID"].downcase.strip
      scale_id = data_item_id.split("-")[0..1].join("-")
      scale = Scale.find_or_create_by!(scale_id:, measure:)
      scale_name = row["Scale Name"]&.strip
      scale_description = row["Scale Description"]&.strip
      scale.name = scale_name
      scale.description = scale_description

      scale.save!

      active_survey_item = row["Active admin & survey items"]
      if %w[Teachers Students Parents].include?(row["Source"]) && %w[TRUE 1].include?(active_survey_item)
        survey_item = SurveyItem.where(survey_item_id: data_item_id, scale:).first_or_create
        survey_item.watch_low_benchmark = watch_low if watch_low
        survey_item.growth_low_benchmark = growth_low if growth_low
        survey_item.approval_low_benchmark = approval_low if approval_low
        survey_item.ideal_low_benchmark = ideal_low if ideal_low
        survey_item.on_short_form = marked? on_short_form
        survey_item.update! prompt: row["Question/item (23-24)"].strip
      end

      active_admin = row["Active admin & survey items"]
      if row["Source"] == "Admin Data" && %w[TRUE 1].include?(active_admin)
        admin_data_item = AdminDataItem.where(admin_data_item_id: data_item_id, scale:).first_or_create
        admin_data_item.watch_low_benchmark = watch_low if watch_low
        admin_data_item.growth_low_benchmark = growth_low if growth_low
        admin_data_item.approval_low_benchmark = approval_low if approval_low
        admin_data_item.ideal_low_benchmark = ideal_low if ideal_low
        admin_data_item.description = row["Question/item (22-23)"]&.strip
        admin_data_item.hs_only_item = marked? row["HS only admin item?"]
        admin_data_item.save!
        admin_data_item_ids << admin_data_item.id
      end
    end
    AdminDataValue.where.not(admin_data_item_id: admin_data_item_ids).delete_all
    AdminDataItem.where.not(id: admin_data_item_ids).delete_all
  end

  def seed_demographics(csv_file)
    DemographicLoader.load_data(filepath: csv_file)
  end

  def seed_enrollment(csv_file)
    EnrollmentLoader.load_data(filepath: csv_file)

    EnrollmentLoader.clone_previous_year_data
  end

  def seed_staffing(csv_file)
    StaffingLoader.load_data(filepath: csv_file)

    StaffingLoader.clone_previous_year_data
  end

  private

  def marked?(mark)
    mark.present? ? mark.upcase.strip == "X" : false
  end

  def remove_commas(target)
    target.delete(",") if target.present?
  end
end
