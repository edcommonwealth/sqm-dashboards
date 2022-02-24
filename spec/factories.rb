FactoryBot.define do
  factory :district do
    name { "#{rand} District" }
    slug { name.parameterize }
  end

  factory :school do
    name { "#{rand} School" }
    slug { name.parameterize }
    sequence(:dese_id, 1000)
    district
  end

  factory :academic_year do
    range { '2050-51' }
    initialize_with { AcademicYear.find_or_initialize_by(range:) }
  end

  factory :category, class: 'Category' do
    name { "A #{rand} category" }
    category_id { rand.to_s }
    description { 'A description of a category' }
    slug { name.parameterize }
    sort_index { 1 }
  end

  factory :subcategory do
    name { 'A subcategory' }
    subcategory_id { rand.to_s }
    description { 'A description of a subcategory' }
    category

    factory :subcategory_with_measures do
      transient do
        measures_count { 2 }
      end
      after(:create) do |subcategory, evaluator|
        create_list(:measure, evaluator.measures_count, subcategory:).each do |measure|
          scale = create(:scale, measure:)
          survey_item = create(:teacher_survey_item, scale:)
          create_list(:survey_item_response, SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD, survey_item:)
        end
      end
    end
  end

  factory :measure do
    measure_id { rand.to_s }
    name { 'A Measure' }
    subcategory
    # trait :with_student_survey_items do
    #   after(:create) do |measure|
    #     measure.survey_items << build_list(:student_survey_item, 2)
    #   end
    # end
  end

  factory :scale do
    measure
    scale_id { "A Scale #{rand}" }
    factory :teacher_scale do
      scale_id { "t-#{rand}" }
    end
    factory :student_scale do
      scale_id { "s-#{rand}" }
    end
  end

  factory :survey_item do
    scale
    prompt { 'What do YOU think?' }
    factory :teacher_survey_item do
      survey_item_id { "t-#{rand}" }
      watch_low_benchmark { 2.0 }
      growth_low_benchmark { 3.0 }
      approval_low_benchmark { 4.0 }
      ideal_low_benchmark { 4.5 }
    end
    factory :student_survey_item do
      survey_item_id { "s-#{rand}" }
      watch_low_benchmark { 2.0 }
      growth_low_benchmark { 3.0 }
      approval_low_benchmark { 4.0 }
      ideal_low_benchmark { 4.5 }
    end
  end

  factory :survey_item_response do
    likert_score { 3 }
    response_id { rand.to_s }
    academic_year
    school
    survey_item factory: :teacher_survey_item
  end

  factory :admin_data_item do
    admin_data_item_id { rand.to_s }
    description { rand.to_s }
    scale
  end

  factory :respondent do
    school
    academic_year
    total_students { SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD * 4 }
    total_teachers { SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD * 4 }
  end
end
