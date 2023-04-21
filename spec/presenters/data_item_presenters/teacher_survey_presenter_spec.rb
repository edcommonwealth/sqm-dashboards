require 'rails_helper'

describe TeacherSurveyPresenter do
  let(:school) { nil }
  let(:academic_year) { nil }
  let(:measure_1A_i) { create(:measure, measure_id: '1A-i') }
  let(:scale_1) { create(:teacher_scale, measure: measure_1A_i) }
  let(:survey_item_1) do
    create(:teacher_survey_item, survey_item_id: 't-1', scale: scale_1,
                                 prompt: 'Given your preparation for teaching how comfortable are you teaching at the grade-level you have been assigned?')
  end
  let(:survey_item_2) do
    create(:teacher_survey_item, survey_item_id: 't-2', scale: scale_1,
                                 prompt: 'How prepared are you for teaching the topics that you are expected to teach in your assignment?')
  end
  let(:survey_item_3) do
    create(:teacher_survey_item, survey_item_id: 't-3', scale: scale_1,
                                 prompt: 'How confident are you in working with the student body at your school?')
  end
  let(:measure_1B_i) { create(:measure, measure_id: '1B-i') }
  let(:scale_2) { create(:teacher_scale, measure: measure_1B_i) }
  let(:survey_item_4) do
    create(:teacher_survey_item, scale: scale_2,
                                 prompt: 'Some prompt that will not be shown.  Instead it will say items will be available upon request to MCIEA')
  end
  before do
    scale_1
    scale_2
    survey_item_1
    survey_item_2
    survey_item_3
    survey_item_4
  end

  describe '#descriptions_and_availability' do
    context 'When the presenter is NOT based on measure 1B-i' do
      it 'returns a list containing the survey item properties' do
        expect(
          TeacherSurveyPresenter.new(
            measure_id: measure_1A_i.measure_id,
            survey_items: measure_1A_i.teacher_survey_items,
            has_sufficient_data: true,
            school:,
            academic_year:
          ).descriptions_and_availability
        ).to eq [
          Summary.new('t-1',
                      'Given your preparation for teaching how comfortable are you teaching at the grade-level you have been assigned?', true),
          Summary.new('t-2',
                      'How prepared are you for teaching the topics that you are expected to teach in your assignment?', true),
          Summary.new('t-3',
                      'How confident are you in working with the student body at your school?', true)
        ]
      end
    end
    context 'When the presenter is based on measure 1B-i' do
      it 'returns a message hiding the actual prompts.  Instead it presents a message telling the user they can ask for more information' do
        expect(
          TeacherSurveyPresenter.new(
            measure_id: measure_1B_i.measure_id,
            survey_items: measure_1B_i.teacher_survey_items,
            has_sufficient_data: true,
            school:,
            academic_year:
          ).descriptions_and_availability
        ).to eq [
          Summary.new('1B-i', 'Items available upon request to Lowell Public Schools', true)
        ]
      end
    end
  end
end
