require 'rails_helper'

describe SurveyResponseAggregator, type: :model do
  let(:category) { SqmCategory.create }
  let(:subcategory) { Subcategory.create sqm_category: category }

  let(:ay_2020_21) { AcademicYear.find_by_range '2020-21' }
  let(:ay_2021_22) { AcademicYear.find_by_range '2021-22' }

  let(:school_a) { School.create name: 'School A' }
  let(:school_b) { School.create name: 'School A' }

  let(:measure_a) { Measure.create subcategory: subcategory, name: 'Measure A', measure_id: 'measure-a-id', watch_low_benchmark: 1.1, growth_low_benchmark: 2, approval_low_benchmark: 3, ideal_low_benchmark: 4 }
  let(:measure_b) { Measure.create subcategory: subcategory, name: 'Measure B', measure_id: 'measure-b-id', watch_low_benchmark: 1.1, growth_low_benchmark: 2, approval_low_benchmark: 3, ideal_low_benchmark: 4 }

  let(:survey_item_1_for_measure_a) { SurveyItem.create measure: measure_a, survey_item_id: 'si1a' }
  let(:survey_item_2_for_measure_a) { SurveyItem.create measure: measure_a, survey_item_id: 'si2a' }

  let(:survey_item_1_for_measure_b) { SurveyItem.create measure: measure_b, survey_item_id: 'si1b' }
  let(:survey_item_2_for_measure_b) { SurveyItem.create measure: measure_b, survey_item_id: 'si2b' }

  before :each do
    SurveyItemResponse.create response_id: '01', academic_year: ay_2020_21, school: school_a, survey_item: survey_item_1_for_measure_a, likert_score: 1
    SurveyItemResponse.create response_id: '02', academic_year: ay_2020_21, school: school_a, survey_item: survey_item_2_for_measure_a, likert_score: 2

    SurveyItemResponse.create response_id: '03', academic_year: ay_2020_21, school: school_a, survey_item: survey_item_1_for_measure_b, likert_score: 1
    SurveyItemResponse.create response_id: '04', academic_year: ay_2020_21, school: school_a, survey_item: survey_item_2_for_measure_b, likert_score: 3

    SurveyItemResponse.create response_id: '05', academic_year: ay_2020_21, school: school_b, survey_item: survey_item_1_for_measure_a, likert_score: 1
    SurveyItemResponse.create response_id: '06', academic_year: ay_2020_21, school: school_b, survey_item: survey_item_2_for_measure_a, likert_score: 4

    SurveyItemResponse.create response_id: '07', academic_year: ay_2020_21, school: school_b, survey_item: survey_item_1_for_measure_b, likert_score: 1
    SurveyItemResponse.create response_id: '08', academic_year: ay_2020_21, school: school_b, survey_item: survey_item_2_for_measure_b, likert_score: 5

    SurveyItemResponse.create response_id: '09', academic_year: ay_2021_22, school: school_a, survey_item: survey_item_1_for_measure_a, likert_score: 2
    SurveyItemResponse.create response_id: '10', academic_year: ay_2021_22, school: school_a, survey_item: survey_item_2_for_measure_a, likert_score: 3

    SurveyItemResponse.create response_id: '11', academic_year: ay_2021_22, school: school_a, survey_item: survey_item_1_for_measure_b, likert_score: 2
    SurveyItemResponse.create response_id: '12', academic_year: ay_2021_22, school: school_a, survey_item: survey_item_2_for_measure_b, likert_score: 4

    SurveyItemResponse.create response_id: '13', academic_year: ay_2021_22, school: school_b, survey_item: survey_item_1_for_measure_a, likert_score: 2
    SurveyItemResponse.create response_id: '14', academic_year: ay_2021_22, school: school_b, survey_item: survey_item_2_for_measure_a, likert_score: 5

    SurveyItemResponse.create response_id: '15', academic_year: ay_2021_22, school: school_b, survey_item: survey_item_1_for_measure_b, likert_score: 3
    SurveyItemResponse.create response_id: '16', academic_year: ay_2021_22, school: school_b, survey_item: survey_item_2_for_measure_b, likert_score: 5
  end

  describe '.score' do
    it 'returns the average score of the survey responses for the given school, academic year, and measure' do
      expect(SurveyResponseAggregator.score(academic_year: ay_2020_21, school: school_a, measure: measure_a)).to eq 1.5
      expect(SurveyResponseAggregator.score(academic_year: ay_2020_21, school: school_a, measure: measure_b)).to eq 2.0

      expect(SurveyResponseAggregator.score(academic_year: ay_2020_21, school: school_b, measure: measure_a)).to eq 2.5
      expect(SurveyResponseAggregator.score(academic_year: ay_2020_21, school: school_b, measure: measure_b)).to eq 3.0

      expect(SurveyResponseAggregator.score(academic_year: ay_2021_22, school: school_a, measure: measure_a)).to eq 2.5
      expect(SurveyResponseAggregator.score(academic_year: ay_2021_22, school: school_a, measure: measure_b)).to eq 3.0

      expect(SurveyResponseAggregator.score(academic_year: ay_2021_22, school: school_b, measure: measure_a)).to eq 3.5
      expect(SurveyResponseAggregator.score(academic_year: ay_2021_22, school: school_b, measure: measure_b)).to eq 4.0
    end
  end
end
