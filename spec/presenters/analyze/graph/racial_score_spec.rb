require 'rails_helper'

include Analyze::Graph::Column

# RacialScore is a module used in the RaceScoreCalculator class
describe RacialScore do
  let(:measure) { create(:measure, :with_student_survey_items) }
  let(:school) { create(:school) }
  let(:academic_year) { create(:academic_year) }
  let(:race) { create(:race) }
  let(:students) do
    [].tap do |arr|
      10.times do
        s = create(:student)
        s.races << race
        s.save
        arr << s
      end
    end
  end
  let(:survey_item_1) { measure.survey_items[0] }
  let(:survey_item_2) { measure.survey_items[1] }
  let(:survey_item_3) { measure.survey_items[2] }
  let(:response_rate) do
    create(:response_rate, school:, academic_year:, subcategory: measure.subcategory, meets_student_threshold: true)
  end

  context 'when sufficient survey item responses exist' do
    before :each do
      response_rate
      students.each do |student|
        create(:survey_item_response, school:, academic_year:, likert_score: 2, survey_item: survey_item_1, student:)
      end
      students.each do |student|
        create(:survey_item_response, school:, academic_year:, likert_score: 3, survey_item: survey_item_2, student:)
      end
    end

    xit 'returns a list of averages' do
      expect(measure.student_survey_items.count).to eq 2

      expect(students.count).to eq 10

      expect(SurveyItemResponse.count).to eq 20

      american_indian_score = RaceScoreCalculator.new(measure:, school:, academic_year:, race:).score
      expect(american_indian_score).to eq Score.new(2.5, false, true, false)
    end
  end

  context 'when there NOT sufficient survey item responses' do
    before :each do
      response_rate
      9.times do |index|
        create(:survey_item_response, school:, academic_year:, likert_score: 2, survey_item: survey_item_1,
                                      student: students[index])
      end

      9.times do |index|
        create(:survey_item_response, school:, academic_year:, likert_score: 3, survey_item: survey_item_2,
                                      student: students[index])
      end
    end
    xit 'returns a list of averages' do
      expect(measure.student_survey_items.count).to eq 2

      expect(SurveyItemResponse.count).to eq 18

      american_indian_score = RaceScoreCalculator.new(measure:, school:, academic_year:, race:).score
      expect(american_indian_score).to eq Score.new(0, false, false, false)
    end
  end
end
