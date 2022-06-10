require 'rails_helper'

describe 'SQM Application' do
  let(:district) { create(:district) }
  let(:school) { create(:school, district:) }
  let(:academic_year) { create(:academic_year) }
  let(:category) { create(:category) }
  let(:measure) { create(:measure) }
  let(:scale) { create(:teacher_scale, measure:) }

  before :each do
    driven_by :rack_test
    page.driver.browser.basic_authorize(username, password)
    create(:respondent, school:, academic_year:)
  end

  context 'when no measures meet their threshold' do
    it 'shows a modal on overview page' do
      visit overview_path
      expect(page).to have_css '.modal'
    end

    it 'does not show a modal on the browse page' do
      visit browse_path
      expect(page).not_to have_css '.modal'
    end
  end

  context 'at least one measure meets its threshold' do
    before :each do
      teacher_survey_item = create(:teacher_survey_item, scale:)
      create_list(:survey_item_response, SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD,
                  survey_item: teacher_survey_item, academic_year:, school:)
    end

    it 'does not show a modal on any page' do
      [overview_path, browse_path].each do |path|
        visit path
        expect(page).not_to have_css '.modal'
      end
    end
  end

  private

  def username
    district.name.downcase
  end

  def password
    "#{username}!"
  end

  def overview_path
    district_school_overview_index_path(district, school, year: academic_year.range)
  end

  def browse_path
    district_school_category_path(district, school, category, year: academic_year.range)
  end
end
