require 'rails_helper'

describe RaceScoreCalculator do
  let(:measure) { create(:measure, :with_student_survey_items) }
  let(:school) { create(:school) }
  let(:academic_year) { create(:academic_year) }
  let(:race) { create(:race) }
  let(:student) do
    s = create(:student)
    s.races << race
    s.save
    s
  end
  let(:survey_item_1) { measure.survey_items[0] }
  let(:survey_item_2) { measure.survey_items[1] }
  let(:survey_item_3) { measure.survey_items[2] }
  let(:response_rate) do
    create(:response_rate, school:, academic_year:, subcategory: measure.subcategory, meets_student_threshold: true)
  end

  xcontext 'when survey item responses exist' do
    before :each do
      response_rate
      create(:survey_item_response, school:, academic_year:, likert_score: 1, survey_item: survey_item_1, student:)
      create_list(:survey_item_response, 8, school:, academic_year:, likert_score: 2, survey_item: survey_item_1,
                                            student:)
      create(:survey_item_response, school:, academic_year:, likert_score: 3, survey_item: survey_item_1, student:)

      create(:survey_item_response, school:, academic_year:, likert_score: 2, survey_item: survey_item_2, student:)
      create_list(:survey_item_response, 8, school:, academic_year:, likert_score: 3, survey_item: survey_item_2,
                                            student:)
      create(:survey_item_response, school:, academic_year:, likert_score: 4, survey_item: survey_item_2, student:)
    end

    it 'returns a list of averages' do
      expect(measure.student_survey_items.count).to eq 2
      american_indian_score = RaceScoreCalculator.new(measure:, school:, academic_year:, race:).score
      expect(american_indian_score).to eq Score.new(2.5, false, true, false)
    end
  end
end
