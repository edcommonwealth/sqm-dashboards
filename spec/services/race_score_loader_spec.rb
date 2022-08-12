require 'rails_helper'

describe RaceScoreLoader do
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

  # I'm not sure how to securely make available the key_derivation_salt for github actions.  Disabling the tests
  context 'when survey item responses exist' do
    before :each do
      response_rate
      students.each do |student|
        create(:survey_item_response, school:, academic_year:, likert_score: 2, survey_item: survey_item_1, student:)
      end
      students.each do |student|
        create(:survey_item_response, school:, academic_year:, likert_score: 3, survey_item: survey_item_2, student:)
      end

      RaceScoreLoader.reset
    end
    xit 'returns a list of averages' do
      expect(measure.student_survey_items.count).to eq 2
      american_indian_score = RaceScore.find_by(measure:, school:, academic_year:, race:)
      expect(american_indian_score.average).to eq 2.5
      expect(american_indian_score.meets_student_threshold).to eq true
    end

    xit 'is idempotent' do
      original_count = RaceScore.count
      RaceScoreLoader.reset
      new_count = RaceScore.count
      expect(original_count).to eq new_count
    end
  end
end
