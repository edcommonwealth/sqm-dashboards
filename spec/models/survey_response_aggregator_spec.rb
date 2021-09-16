require 'rails_helper'

describe SurveyResponseAggregator, type: :model do
  let(:ay_2020_21) { '2020-21' }
  let(:ay_2021_22) { '2021-22' }

  let(:school_a) { School.create name: 'School A' }
  let(:school_b) { School.create name: 'School A' }

  let(:construct_a) { Construct.create name: 'Construct A', construct_id: 'construct-a-id' }
  let(:construct_b) { Construct.create name: 'Construct B', construct_id: 'construct-b-id' }

  let(:survey_item_1_for_construct_a) { SurveyItem.create construct: construct_a }
  let(:survey_item_2_for_construct_a) { SurveyItem.create construct: construct_a }

  let(:survey_item_1_for_construct_b) { SurveyItem.create construct: construct_b }
  let(:survey_item_2_for_construct_b) { SurveyItem.create construct: construct_b }

  before :each do
    SurveyResponse.create academic_year: ay_2020_21, school: school_a, survey_item: survey_item_1_for_construct_a, likert_score: 1
    SurveyResponse.create academic_year: ay_2020_21, school: school_a, survey_item: survey_item_2_for_construct_a, likert_score: 2

    SurveyResponse.create academic_year: ay_2020_21, school: school_a, survey_item: survey_item_1_for_construct_b, likert_score: 1
    SurveyResponse.create academic_year: ay_2020_21, school: school_a, survey_item: survey_item_2_for_construct_b, likert_score: 3

    SurveyResponse.create academic_year: ay_2020_21, school: school_b, survey_item: survey_item_1_for_construct_a, likert_score: 1
    SurveyResponse.create academic_year: ay_2020_21, school: school_b, survey_item: survey_item_2_for_construct_a, likert_score: 4

    SurveyResponse.create academic_year: ay_2020_21, school: school_b, survey_item: survey_item_1_for_construct_b, likert_score: 1
    SurveyResponse.create academic_year: ay_2020_21, school: school_b, survey_item: survey_item_2_for_construct_b, likert_score: 5

    SurveyResponse.create academic_year: ay_2021_22, school: school_a, survey_item: survey_item_1_for_construct_a, likert_score: 2
    SurveyResponse.create academic_year: ay_2021_22, school: school_a, survey_item: survey_item_2_for_construct_a, likert_score: 3

    SurveyResponse.create academic_year: ay_2021_22, school: school_a, survey_item: survey_item_1_for_construct_b, likert_score: 2
    SurveyResponse.create academic_year: ay_2021_22, school: school_a, survey_item: survey_item_2_for_construct_b, likert_score: 4

    SurveyResponse.create academic_year: ay_2021_22, school: school_b, survey_item: survey_item_1_for_construct_a, likert_score: 2
    SurveyResponse.create academic_year: ay_2021_22, school: school_b, survey_item: survey_item_2_for_construct_a, likert_score: 5

    SurveyResponse.create academic_year: ay_2021_22, school: school_b, survey_item: survey_item_1_for_construct_b, likert_score: 3
    SurveyResponse.create academic_year: ay_2021_22, school: school_b, survey_item: survey_item_2_for_construct_b, likert_score: 5
  end

  describe '.score' do
    it 'returns the average score of the survey responses for the given school, academic year, and construct' do
      expect(SurveyResponseAggregator.score(academic_year: ay_2020_21, school: school_a, construct: construct_a)).to eq 1.5
      expect(SurveyResponseAggregator.score(academic_year: ay_2020_21, school: school_a, construct: construct_b)).to eq 2.0

      expect(SurveyResponseAggregator.score(academic_year: ay_2020_21, school: school_b, construct: construct_a)).to eq 2.5
      expect(SurveyResponseAggregator.score(academic_year: ay_2020_21, school: school_b, construct: construct_b)).to eq 3.0

      expect(SurveyResponseAggregator.score(academic_year: ay_2021_22, school: school_a, construct: construct_a)).to eq 2.5
      expect(SurveyResponseAggregator.score(academic_year: ay_2021_22, school: school_a, construct: construct_b)).to eq 3.0

      expect(SurveyResponseAggregator.score(academic_year: ay_2021_22, school: school_b, construct: construct_a)).to eq 3.5
      expect(SurveyResponseAggregator.score(academic_year: ay_2021_22, school: school_b, construct: construct_b)).to eq 4.0
    end
  end
end
