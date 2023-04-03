require 'rails_helper'

RSpec.describe Report::Pillar, type: :model do
  let(:school) { create(:school, name: 'Abraham Lincoln Elementary School') }
  let(:subcategory) { create(:subcategory, subcategory_id: '1A') }
  let(:measure_1) { create(:measure, measure_id: '1A-iii', subcategory:) }
  let(:measure_2) { create(:measure, measure_id: '1B-ii', subcategory:) }
  let(:scale_1) { create(:scale, measure: measure_1) }
  let(:scale_2) { create(:scale, measure: measure_2) }
  let(:survey_item_1) { create(:student_survey_item, scale: scale_1) }
  let(:survey_item_2) do
    create(:student_survey_item, scale: scale_2, ideal_low_benchmark: 5)
  end
  let(:measures) do
    subcategory.measures
  end
  let(:academic_year_1) { create(:academic_year, range: '2017-2018') }
  let(:academic_year_2) { create(:academic_year, range: '2018-2019') }
  let(:academic_years) { [academic_year_1, academic_year_2] }

  before :each do
    create(:respondent, school:, academic_year: academic_year_1)
    create(:survey, school:, academic_year: academic_year_1)
    measures
  end

  context '.pillar' do
    it 'returns the GPS pillar' do
      pillar = Report::Pillar.new(school:, measures:, indicator: 'Teaching Environment',
                                  period: 'Current', academic_year: academic_year_1)
      expect(pillar.pillar).to eq('Operational Efficiency')
    end
  end

  context '.school' do
    it 'returns the name of the school' do
      pillar = Report::Pillar.new(school:, measures:, indicator: 'The Teaching Environment', period: 'Current',
                                  academic_year: academic_year_1)
      expect(pillar.school_name).to eq('Abraham Lincoln Elementary School')
    end
  end

  context '.score' do
    before do
      create_list(:survey_item_response, SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD, survey_item: survey_item_1, school:, academic_year: academic_year_1,
                                                                                         likert_score: 3)
      create_list(:survey_item_response, SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD, survey_item: survey_item_1, school:, academic_year: academic_year_1,
                                                                                         likert_score: 5)
    end
    it 'returns the average score for all the measures in the pillar' do
      pillar = Report::Pillar.new(school:, measures:, indicator: 'The Teaching Environment', period: 'Current',
                                  academic_year: academic_year_1)
      expect(pillar.score).to eq 4
    end
  end

  context '.zone' do
    before do
      create_list(:survey_item_response, SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD, survey_item: survey_item_1, school:, academic_year: academic_year_1,
                                                                                         likert_score: 4)
      create_list(:survey_item_response, SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD, survey_item: survey_item_1, school:, academic_year: academic_year_1,
                                                                                         likert_score: 5)
      create_list(:survey_item_response, SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD, survey_item: survey_item_2, school:, academic_year: academic_year_1,
                                                                                         likert_score: 4)
      create_list(:survey_item_response, SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD, survey_item: survey_item_2, school:, academic_year: academic_year_1,
                                                                                         likert_score: 5)
    end

    it 'returns the zone for the average score for all the measures in the pillar' do
      pillar = Report::Pillar.new(school:, measures:, indicator: 'The Teaching Environment', period: 'Current',
                                  academic_year: academic_year_1)
      expect(pillar.score).to eq 4.5
      expect(pillar.zone).to eq 'Approval'
    end
  end
end
