require 'csv'

academic_year_ranges = ['2020-21', '2021-22']
academic_year_ranges.each do |range|
  AcademicYear.create range: range if AcademicYear.find_by_range(range).nil?
end

qualtrics_district_and_school_code_key = File.read(Rails.root.join('data', 'qualtrics_district_and_school_code_key.csv'))
CSV.parse(qualtrics_district_and_school_code_key, headers: true).each do |row|
  district_name = row['District']
  district_code = row['District Code']
  school_name = row['School Name']
  school_code = row['School Code']
  school_slug = school_name.parameterize

  district = District.find_by_name(district_name)
  if district.nil?
    District.create name: district_name, qualtrics_code: district_code, slug: district_name.parameterize, state_id: 1
  else
    district.update(qualtrics_code: district_code) if district.qualtrics_code.nil?
  end
  district = District.find_by_name(district_name)

  school = School.find_by_slug(school_slug)
  if school.nil?
    School.create district: district, name: school_name, qualtrics_code: school_code, slug: school_slug
  else
    school.update(qualtrics_code: school_code) if school.qualtrics_code.nil?
  end
end

measure_key_2021 = File.read(Rails.root.join('data', '2021-measure-key.csv'))
CSV.parse(measure_key_2021, headers: true).each do |row|
  category_name = row['Category']

  category = SqmCategory.find_or_create_by(name: category_name)

  category_slugs = {
    'Teachers & Leadership' => 'teachers-and-leadership',
    'School Culture' => 'school-culture',
    'Resources' => 'resources',
    'Academic Learning' => 'academic-learning',
    'Community & Wellbeing' => 'community-and-wellbeing',
  }

  category.description = row['Category Description']
  category.slug = category_slugs[category_name]
  category.sort_index = category_slugs.keys.index(category_name)
  category.save

  subcategory_name = row['Subcategory']

  subcategory = Subcategory.find_or_create_by(name: subcategory_name, sqm_category: category)
  subcategory.description = row['Subcategory Description']
  subcategory.save

  measure_id = row['Measure Id']
  watch_low = row['Watch Low']
  growth_low = row['Growth Low']
  approval_low = row['Approval Low']
  ideal_low = row['Ideal Low']
  measure = Measure.find_or_create_by(measure_id: measure_id, subcategory: subcategory, watch_low_benchmark: watch_low, growth_low_benchmark: growth_low, approval_low_benchmark: approval_low, ideal_low_benchmark: ideal_low)
  measure.name = row['Measures']
  measure.description = row['Measure Description']
  measure.save

  unless row['Source'] == 'Admin Data'
    survey_item_id = row['Survey Item ID']

    next if survey_item_id.nil?

    survey_item = SurveyItem.find_or_create_by(survey_item_id: survey_item_id, measure: measure)
    item_prompt = row['Revised Question'].nil? ? row['Question/Item'] : row['Revised Question']
    survey_item.prompt = item_prompt
    survey_item.save
  end
end
