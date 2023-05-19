require 'rails_helper'
RSpec.describe Report::Subcategory, type: :model do
  let(:school) { create(:school, name: 'Milford High', slug: 'milford-high') }
  let(:academic_year) { create(:academic_year, range: '2018-2019') }
  let(:subcategory) { create(:subcategory, subcategory_id: '1A') }
  before :each do
    school
    academic_year
    subcategory
  end
  let(:measure) { create(:measure, subcategory:) }
  let(:scale) { create(:scale, measure:) }
  let(:survey_item) { create(:student_survey_item, scale:) }

  context 'when creating a report for a subcategory' do
    before :each do
      create_list(:survey_item_response, 10, survey_item:, school:, academic_year:)
    end

    it 'creates a report for subcategories' do
      expect(Report::Subcategory.create_report).to be_a(Array)
      headers = Report::Subcategory.create_report.first
      expect(headers).to eq(['School', 'Academic Year', 'Subcategory', 'Student Score',
                             'Student Zone', 'Teacher Score', 'Teacher Zone', 'Admin Score', 'Admin Zone', 'All Score (Average)', 'All Score Zone'])
    end

    it 'Adds information about the first school and first academic year to the report' do
      report = Report::Subcategory.create_report
      report[1] in [school_name, academic_year, subcategory_id, *]
      expect(school_name).to eq('Milford High')
      expect(academic_year).to eq('2018-2019')
      expect(subcategory_id).to eq('1A')
    end
  end
end
