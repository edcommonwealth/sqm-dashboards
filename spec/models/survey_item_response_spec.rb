require 'rails_helper'
RSpec.describe SurveyItemResponse, type: :model do
  let(:district) { create(:district) }
  let(:boston) { create(:district, name: 'Boston') }
  let(:school) { create(:school, district:) }
  let(:boston_school) { create(:school, district: boston) }
  let(:academic_year) { create(:academic_year) }
  let(:survey_item) { create(:student_survey_item) }

  before :each do
    create(:survey_item_response, school:, survey_item:)
    create(:survey_item_response, school: boston_school, survey_item:)
  end
  describe '.survey_item_responses' do
    it 'includes all survey item responses' do
      expect(survey_item.survey_item_responses.count).to eq 2
    end
  end
  describe '.exclude_boston' do
    it 'excludes survey item responses from boston schools' do
      expect(survey_item.survey_item_responses.exclude_boston.count).to eq 1
    end
  end
end
