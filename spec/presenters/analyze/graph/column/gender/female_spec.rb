require 'rails_helper'
include Analyze::Graph
include Analyze::Graph::Column::GenderColumn
describe StudentsByRace do
  let(:female) { create(:gender, qualtrics_code: 1, designation: 'Female') }
  let(:school) { create(:school) }
  let(:academic_year) { create(:academic_year, range: '1900-01') }
  let(:academic_years) { [academic_year] }
  let(:year_index) { academic_years.find_index(academic_year) }

  let(:measure_with_student_survey_items) { create(:measure, name: 'Student measure') }
  let(:scale_with_student_survey_item) { create(:student_scale, measure: measure_with_student_survey_items) }
  let(:student_survey_item) do
    create(:student_survey_item, scale: scale_with_student_survey_item)
  end

  before do
    create_list(:survey_item_response, 1, survey_item: student_survey_item, school:, academic_year:, gender: female)
  end

  context '.gender' do
    it 'returns female gender' do
      expect(Female.new(measure: measure_with_student_survey_items, school:, academic_years:, position: year_index,
                        number_of_columns: 1).gender).to eq female
    end

    it 'returns the count of survey items for females for that school and academic_year ' do
      female_column = Female.new(measure: measure_with_student_survey_items, school:, academic_years:, position: year_index,
                                 number_of_columns: 1)
      expect(female_column.sufficient_student_responses?(academic_year:)).to eq false
    end

    context 'when there are more than 10 students who responded' do
      before do
        create_list(:survey_item_response, 10, survey_item: student_survey_item, school:, academic_year:,
                                               gender: female)
      end
      it 'returns the count of survey items for females for that school and academic_year ' do
        female_column = Female.new(measure: measure_with_student_survey_items, school:, academic_years:, position: year_index,
                                   number_of_columns: 1)
        expect(female_column.sufficient_student_responses?(academic_year:)).to eq true
      end
    end
  end
end
