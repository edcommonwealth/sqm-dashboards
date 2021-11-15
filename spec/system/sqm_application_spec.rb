require 'rails_helper'

describe 'SQM Application' do
  let(:district) { create(:district) }
  let(:school) { create(:school, district: district) }
  let(:academic_year) { create(:academic_year) }
  let(:category) { create(:category) }
  let(:measure) { create(:measure) }

  before :each do
    driven_by :rack_test
    page.driver.browser.basic_authorize(username, password)
  end

  context 'when no measures meet their threshold' do
    it 'shows a modal on all pages' do
      [dashboard_path, browse_path].each do |path|
        visit path
        expect(page).to have_css '.modal'
      end
    end
  end

  context 'at least one measure meets its threshold' do
    before :each do
      teacher_survey_item = create(:teacher_survey_item, measure: measure)
      create_list(:survey_item_response, SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD,
                  survey_item: teacher_survey_item, academic_year: academic_year, school: school)
    end

    it 'does not show a modal on any page' do
      [dashboard_path, browse_path].each do |path|
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

  def dashboard_path
    district_school_dashboard_index_path(district, school, year: academic_year.range)
  end

  def browse_path
    district_school_category_path(district, school, category, year: academic_year.range)
  end
end
