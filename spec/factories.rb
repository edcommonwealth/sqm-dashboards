FactoryBot.define do

  factory :district do
    name { "#{rand} District" }
    slug { name.parameterize }
  end

  factory :school do
    name { "#{rand} School" }
    slug { name.parameterize }
    dese_id { rand(1000) }
    district
  end

  factory :academic_year do
    range { '2050-51' }
    initialize_with { AcademicYear.find_or_initialize_by(range: range) }
  end

  factory :category, class: 'Category' do
    name { "A #{rand} category" }
    category_id { rand.to_s }
    description { "A description of a category" }
    slug { name.parameterize }
    sort_index { 1 }
  end

  factory :subcategory do
    name { "A subcategory" }
    subcategory_id { rand.to_s }
    description { "A description of a subcategory" }
    category

    factory :subcategory_with_measures do
      transient do
        measures_count { 2 }
      end
      after(:create) do |subcategory, evaluator|
        create_list(:measure, evaluator.measures_count, subcategory: subcategory). each do |measure|
          survey_item = create(:teacher_survey_item, measure: measure)
          create_list(:survey_item_response, SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD, survey_item: survey_item)
        end
      end
    end
  end

  factory :measure do
    measure_id { rand.to_s }
    name { 'A Measure' }
    watch_low_benchmark { 2.0 }
    growth_low_benchmark { 3.0 }
    approval_low_benchmark { 4.0 }
    ideal_low_benchmark { 4.5 }
    subcategory
  end

  factory :survey_item do
    prompt { 'What do YOU think?' }
    measure
    factory :teacher_survey_item do
      survey_item_id { "t-#{rand.to_s}" }
    end
    factory :student_survey_item do
      survey_item_id { "s-#{rand.to_s}" }
    end
  end


  factory :survey_item_response do
    likert_score { 3 }
    response_id { rand.to_s }
    academic_year
    school
    survey_item
  end

  factory :admin_data_item do
    admin_data_item_id { rand.to_s }
    description { rand.to_s }
    measure
  end
end
