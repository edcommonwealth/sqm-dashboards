require 'rails_helper'

describe MeasurePresenter do
  let(:academic_year) { create(:academic_year, range: '1989-90') }
  let(:school) { create(:school, name: 'Best School') }
  let(:measure) { create(:measure, measure_id: 'measure-id') }
  let(:teacher_scale) { create(:teacher_scale, measure:) }
  let(:student_scale) { create(:student_scale, measure:) }
  let(:admin_scale) { create(:scale, measure:) }
  let(:measure_presenter) { MeasurePresenter.new(measure:, academic_year:, school:) }
  before do
    create(:respondent, school:, academic_year:)
    create(:survey, school:, academic_year:)
  end

  it 'returns the id of the measure' do
    expect(measure_presenter.id).to eq 'measure-id'
  end

  it 'has an id for use in the data item accordions' do
    expect(measure_presenter.data_item_accordion_id).to eq 'data-item-accordion-measure-id'
  end

  context 'when the measure contains only teacher data' do
    before :each do
      survey_item1 = create(:teacher_survey_item, scale: teacher_scale, prompt: 'A teacher survey item prompt')
      survey_item2 = create(:teacher_survey_item, scale: teacher_scale, prompt: 'Another teacher survey item prompt')

      create_list(:survey_item_response, SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD, survey_item: survey_item1,
                                                                                         academic_year:, school:, likert_score: 1)
      create_list(:survey_item_response, SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD, survey_item: survey_item2,
                                                                                         academic_year:, school:, likert_score: 5)
    end

    it 'creates a gauge presenter that presents the average likert score' do
      expect(measure_presenter.gauge_presenter.title).to eq 'Growth'
    end

    it 'returns a list of data item presenters that has only one element, and that element has a title of "Teacher survey"' do
      expect(measure_presenter.data_item_presenters.count).to eq 1
      expect(measure_presenter.data_item_presenters.first.id).to eq 'teacher-survey-items-measure-id'
      expect(measure_presenter.data_item_presenters.first.title).to eq 'Teacher survey'
      expect(measure_presenter.data_item_presenters.first.data_item_accordion_id).to eq 'data-item-accordion-measure-id'
      expect(measure_presenter.data_item_presenters.first.item_descriptions).to eq ['A teacher survey item prompt',
                                                                                    'Another teacher survey item prompt']
    end
  end

  context 'when the measure contains both teacher data and admin data' do
    before :each do
      create(:teacher_survey_item, scale: teacher_scale, prompt: 'A teacher survey item prompt')
      create(:teacher_survey_item, scale: teacher_scale, prompt: 'Another teacher survey item prompt')
      create(:admin_data_item, scale: admin_scale, description: 'An admin data item description')
      create(:admin_data_item, scale: admin_scale, description: 'Another admin data item description')
    end

    it 'returns a list of data item presenters with two elements' do
      expect(measure_presenter.data_item_presenters.count).to eq 2

      first_data_item_presenter = measure_presenter.data_item_presenters[0]
      expect(first_data_item_presenter.id).to eq 'teacher-survey-items-measure-id'
      expect(first_data_item_presenter.title).to eq 'Teacher survey'
      expect(first_data_item_presenter.data_item_accordion_id).to eq 'data-item-accordion-measure-id'
      expect(first_data_item_presenter.item_descriptions).to eq ['A teacher survey item prompt',
                                                                 'Another teacher survey item prompt']

      second_data_item_presenter = measure_presenter.data_item_presenters[1]
      expect(second_data_item_presenter.id).to eq 'admin-data-items-measure-id'
      expect(second_data_item_presenter.title).to eq 'School admin data'
      expect(second_data_item_presenter.data_item_accordion_id).to eq 'data-item-accordion-measure-id'
      expect(second_data_item_presenter.item_descriptions).to eq ['An admin data item description',
                                                                  'Another admin data item description']
    end
  end

  context 'when the measure has partial data for teachers and students' do
    before :each do
      teacher_survey_item = create(:teacher_survey_item, scale: teacher_scale)
      student_survey_item = create(:student_survey_item, scale: student_scale)

      create_list(:survey_item_response, SurveyItemResponse::TEACHER_RESPONSE_THRESHOLD,
                  survey_item: teacher_survey_item, academic_year:, school:)
      create_list(:survey_item_response, SurveyItemResponse::STUDENT_RESPONSE_THRESHOLD - 1,
                  survey_item: student_survey_item, academic_year:, school:)
    end

    it 'tracks which parts of the data are sufficient' do
      teacher_data_item_presenter = measure_presenter.data_item_presenters.find do |presenter|
        presenter.title == 'Teacher survey'
      end
      student_data_item_presenter = measure_presenter.data_item_presenters.find do |presenter|
        presenter.title == 'Student survey'
      end
      expect(teacher_data_item_presenter.sufficient_data?).to be true
      expect(student_data_item_presenter.sufficient_data?).to be false
    end
  end

  context 'when the measure has insufficient admin data and insufficient teacher/student data' do
    before :each do
      create(:admin_data_item, scale: admin_scale)
      create(:teacher_survey_item, scale: teacher_scale)
      create(:student_survey_item, scale: student_scale)
    end

    it 'tracks the reason for their insufficiency' do
      teacher_data_item_presenter = measure_presenter.data_item_presenters.find do |presenter|
        presenter.title == 'Teacher survey'
      end
      student_data_item_presenter = measure_presenter.data_item_presenters.find do |presenter|
        presenter.title == 'Student survey'
      end
      admin_data_item_presenter = measure_presenter.data_item_presenters.find do |presenter|
        presenter.title == 'School admin data'
      end
      expect(teacher_data_item_presenter.reason_for_insufficiency).to eq 'low response rate'
      expect(student_data_item_presenter.reason_for_insufficiency).to eq 'low response rate'
      expect(admin_data_item_presenter.reason_for_insufficiency).to eq 'limited availability'
    end
  end
end
