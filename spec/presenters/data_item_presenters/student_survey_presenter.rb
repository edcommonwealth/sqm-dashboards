require 'rails_helper'

describe StudentSurveyPresenter do
  let(:school) { nil }
  let(:academic_year) { nil }
  let(:measure_1A_i) { create(:measure, measure_id: '1A-i') }
  let(:scale_1) { create(:student_scale, measure: measure_1A_i) }
  let(:survey_item_1) do
    create(:student_survey_item, survey_item_id: 's-sbel-q1', scale: scale_1,
                                 prompt: 'I am happy when I am in class.')
  end
  let(:survey_item_2) do
    create(:student_survey_item, survey_item_id: 's-sbel-q2', scale: scale_1,
                                 prompt: 'My teacher gives me help when I need it.')
  end
  let(:survey_item_3) do
    create(:student_survey_item, survey_item_id: 's-sbel-es1', scale: scale_1,
                                 prompt: 'This prompt should not show up')
  end
  let(:measure_1B_i) { create(:measure, measure_id: '1B-i') }
  before do
    scale_1
    survey_item_1
    survey_item_2
    survey_item_3
  end

  describe '#descriptions_and_availability' do
    context 'When there is a survey item with a blank prompt' do
      it 'returns a list containing the survey item properties excluding survey items with blank prompts' do
        result = StudentSurveyPresenter.new(
          measure_id: measure_1A_i.measure_id,
          survey_items: measure_1A_i.student_survey_items,
          has_sufficient_data: true,
          school:,
          academic_year:
        ).descriptions_and_availability
        expect(
          result
        ).to eq [
          Summary.new('s-sbel-q1',
                      'I am happy when I am in class.', true),
          Summary.new('s-sbel-q2',
                      'My teacher gives me help when I need it.', true)
        ]
      end
    end
  end
end
