require 'csv'

class Seeder
  def seed_academic_years(*academic_year_ranges)
    academic_year_ranges.each do |range|
      AcademicYear.find_or_create_by! range: range
    end
  end

  def seed_districts_and_schools csv_file
    CSV.parse(File.read(csv_file), headers: true) do |row|
      district_name = row['District'].strip
      district_code = row['District Code'].strip
      school_name = row['School Name'].strip
      school_code = row['School Code'].strip

      district = District.find_or_create_by! name: district_name
      district.update! slug: district_name.parameterize, qualtrics_code: district_code

      school = School.find_or_create_by! name: school_name, district: district
      school.update! qualtrics_code: school_code
    end
  end

  def seed_sqm_framework csv_file
    CSV.parse(File.read(csv_file), headers: true) do |row|
      category_name = row['Category'].strip

      category = SqmCategory.find_or_create_by!(name: category_name)
      category_slugs = {
        'Teachers & Leadership' => 'teachers-and-leadership',
        'School Culture' => 'school-culture',
        'Resources' => 'resources',
        'Academic Learning' => 'academic-learning',
        'Citizenship & Wellbeing' => 'citizenship-and-wellbeing',
      }
      category.update! description: row['Category Description'].strip, slug: category_slugs[category_name], sort_index: category_slugs.keys.index(category_name)

      subcategory_name = row['Subcategory'].strip
      subcategory = Subcategory.find_or_create_by! name: subcategory_name, sqm_category: category
      subcategory.update! description: row['Subcategory Description'].strip

      measure_id = row['Measure ID'].strip
      measure_name = row['Measures'].try(:strip)
      watch_low = row['Watch Low'].try(:strip)
      growth_low = row['Growth Low'].try(:strip)
      approval_low = row['Approval Low'].try(:strip)
      ideal_low = row['Ideal Low'].try(:strip)

      next if row['Source'] == 'No source'
      measure = Measure.find_or_create_by! measure_id: measure_id, subcategory: subcategory
      measure.name = measure_name

      if ['Teachers', 'Students'].include? row['Source']
        measure.watch_low_benchmark = watch_low if watch_low
        measure.growth_low_benchmark = growth_low if growth_low
        measure.approval_low_benchmark = approval_low if approval_low
        measure.ideal_low_benchmark = ideal_low if ideal_low
      end
      measure.save!

      data_item_id = row['Survey Item ID'].strip
      if ['Teachers', 'Students'].include? row['Source']
        survey_item = SurveyItem.find_or_create_by! survey_item_id: data_item_id, measure: measure
        survey_item.update! prompt: row['Question/item (20-21)'].strip
      end

      if row['Source'] == 'Admin Data'
        admin_data_item = AdminDataItem.find_or_create_by! admin_data_item_id: data_item_id, measure: measure
        admin_data_item.update! description: row['Question/item (20-21)'].strip
      end
    end
  end
end