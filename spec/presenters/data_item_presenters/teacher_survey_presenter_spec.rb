require 'rails_helper'

describe TeacherSurveyPresenter do
  let(:measure_1A_i) { Measure.find_by_measure_id '1A-i' }
  let(:measure_1B_i) { Measure.find_by_measure_id '1B-i' }
  describe '#item_description' do
    before :each do
      Rails.application.load_seed
    end

    after :each do
      DatabaseCleaner.clean
    end

    context 'When the presenter is based on measure 1A-1' do
      it 'returns a list of survey prompts for teacher survey items' do
        expect(TeacherSurveyPresenter.new(measure_id: measure_1A_i.measure_id, survey_items: measure_1A_i.teacher_survey_items,
                                          has_sufficient_data: true).item_descriptions).to eq [
                                            'Given your preparation for teaching how comfortable are you teaching at the grade-level you have been assigned?',
                                            'How prepared are you for teaching the topics that you are expected to teach in your assignment?',
                                            'How confident are you in working with the student body at your school?'
                                          ]
      end
    end

    context 'When the presenter is based on measure 1B-i' do
      it 'returns a message hiding the actual prompts.  Instead it presents a message telling the user they can ask for more information' do
        expect(TeacherSurveyPresenter.new(measure_id: measure_1B_i.measure_id, survey_items: measure_1B_i.teacher_survey_items,
                                          has_sufficient_data: true).item_descriptions).to eq [
                                            'Items available upon request to MCIEA.'
                                          ]
      end
    end
  end
end
