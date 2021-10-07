FactoryBot.define do

  factory :district do
    name { "#{rand} District" }
    slug { name.parameterize }
  end

  factory :school do
    name { "#{rand} School" }
    slug { name.parameterize }
    district
  end

  factory :academic_year do
    range { '2050-51' }
  end

  factory :sqm_category do
    name { "A category" }
    description { "A description of a category" }
    slug { 'a-category' }
    sort_index { 1 }
  end

  factory :subcategory do
    name { "A subcategory" }
    description { "A description of a subcategory" }
    sqm_category

    factory :subcategory_with_measures do
      transient do
        measures_count { 2 }
      end
      after(:create) do |subcategory, evaluator|
        create_list(:measure, evaluator.measures_count, subcategory: subcategory)
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
    survey_item_id { rand.to_s }
    measure
  end

  factory :survey_item_response do
    likert_score { 3 }
    response_id { rand.to_s }
    academic_year
    school
    survey_item
  end
end
