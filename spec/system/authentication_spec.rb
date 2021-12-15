require 'rails_helper'

describe 'authentication' do
  let(:district) { create(:district) }
  let(:school) { create(:school, district: district) }
  let(:academic_year) { create(:academic_year) }

  context 'when using the wrong credentials' do
    before :each do
      page.driver.browser.basic_authorize('wrong username', 'wrong password')
    end
    it 'does not show any information' do
      visit overview_path

      expect(page).not_to have_text(school.name)
    end
  end

  context 'when using the right credentials' do
    before :each do
      page.driver.browser.basic_authorize(username, password)
    end
    it 'does show information' do
      visit overview_path

      expect(page).to have_text(school.name)
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
end
