require 'csv'

csv_file = File.read(Rails.root.join('data', '2021-measure-key.csv'))
CSV.parse(csv_file, headers: true).each do |row|
  next if row['Source'] == 'Admin Data'

  category_name = row['Category']

  if SqmCategory.find_by_name(category_name).nil?
    SqmCategory.create name: category_name
  end

  subcategory_name = row['Subcategory']

  if Subcategory.find_by_name(subcategory_name).nil?
    Subcategory.create sqm_category: SqmCategory.find_by_name(category_name), name: subcategory_name
  end

  measure_id = row['Measure Id']

  if Measure.find_by_measure_id(measure_id).nil?
    measure_name = row['Measures']
    watch_low = row['Watch Low']
    growth_low = row['Growth Low']
    approval_low = row['Approval Low']
    ideal_low = row['Ideal Low']
    Measure.create subcategory: Subcategory.find_by_name(subcategory_name), measure_id: measure_id, name: measure_name, watch_low_benchmark: watch_low, growth_low_benchmark: growth_low, approval_low_benchmark: approval_low, ideal_low_benchmark: ideal_low
  end

  survey_item_id = row['Survey Item ID']

  next if survey_item_id.nil?

  if SurveyItem.find_by_survey_item_id(survey_item_id).nil?
    item_prompt = row['Revised Question'].nil? ? row['Question/Item'] : row['Revised Question']
    SurveyItem.create measure: Measure.find_by_measure_id(measure_id), prompt: item_prompt, survey_item_id: survey_item_id
  end
end
