require 'rails_helper'

describe GroupedBarColumnPresenter do
  let(:school) { create(:school) }
  let(:academic_year) { create(:academic_year) }
  let(:watch_low_benchmark) { 2 }
  let(:growth_low_benchmark) { 3 }
  let(:approval_low_benchmark) { 4 }
  let(:ideal_low_benchmark) { 4.5 }

  let(:measure_with_student_survey_items) { create(:measure, name: 'Student measure') }
  let(:scale_with_student_survey_item) { create(:student_scale, measure: measure_with_student_survey_items) }
  let(:student_survey_item) do
    create(:student_survey_item, scale: scale_with_student_survey_item,
                                 watch_low_benchmark:,
                                 growth_low_benchmark:,
                                 approval_low_benchmark:,
                                 ideal_low_benchmark:)
  end

  let(:measure_with_teacher_survey_items) { create(:measure, name: 'Teacher measure') }
  let(:scale_with_teacher_survey_item) { create(:teacher_scale, measure: measure_with_teacher_survey_items) }
  let(:teacher_survey_item) do
    create(:teacher_survey_item, scale: scale_with_teacher_survey_item,
                                 watch_low_benchmark:,
                                 growth_low_benchmark:,
                                 approval_low_benchmark:,
                                 ideal_low_benchmark:)
  end

  let(:measure_composed_of_student_and_teacher_items) { create(:measure, name: 'Student and teacher measure') }
  let(:student_scale_for_composite_measure) do
    create(:student_scale, measure: measure_composed_of_student_and_teacher_items)
  end
  let(:student_survey_item_for_composite_measure) do
    create(:student_survey_item, scale: student_scale_for_composite_measure,
                                 watch_low_benchmark:,
                                 growth_low_benchmark:,
                                 approval_low_benchmark:,
                                 ideal_low_benchmark:)
  end
  let(:teacher_scale_for_composite_measure) do
    create(:teacher_scale, measure: measure_composed_of_teacher_and_teacher_items)
  end
  let(:teacher_survey_item_for_composite_measure) do
    create(:teacher_survey_item, scale: teacher_scale_for_composite_measure,
                                 watch_low_benchmark:,
                                 growth_low_benchmark:,
                                 approval_low_benchmark:,
                                 ideal_low_benchmark:)
  end

  let(:measure_without_admin_data_items) do
    create(
      :measure,
      name: 'Some Title'
    )
  end

  let(:student_presenter) do
    StudentGroupedBarColumnPresenter.new measure: measure_with_student_survey_items, school:, academic_year:,
                                         position: 1
  end

  let(:teacher_presenter) do
    TeacherGroupedBarColumnPresenter.new measure: measure_with_teacher_survey_items, school:, academic_year:,
                                         position: 1
  end

  let(:all_data_presenter) do
    GroupedBarColumnPresenter.new measure: measure_composed_of_student_and_teacher_items, school:, academic_year:,
                                  position: 1
  end

  before do
    create(:respondent, school:, academic_year:, total_students: 1, total_teachers: 1)
    create(:survey, form: :normal, school:, academic_year:)
  end

  shared_examples_for 'measure_name' do
    it 'returns the measure name' do
      expect(student_presenter.measure_name).to eq 'Student measure'
    end
  end

  context 'when a measure is based on student survey items' do
    context 'when the score is in the Ideal zone' do
      before do
        create(:survey_item_response,  survey_item: student_survey_item, school:,
                                       academic_year:, likert_score: 5)
        create(:survey_item_response,  survey_item: student_survey_item, school:,
                                       academic_year:, likert_score: 4)
      end

      it_behaves_like 'measure_name'

      it 'returns the correct color' do
        expect(student_presenter.bar_color).to eq 'fill-ideal'
      end

      it 'returns a bar width equal to the approval zone width plus the proportionate ideal zone width' do
        expect(student_presenter.bar_height_percentage).to be_within(0.01).of(17)
      end

      it 'returns a y_offset equal to the ' do
        expect(student_presenter.y_offset).to be_within(0.01).of(17)
      end
    end

    context 'when the score is in the Approval zone' do
      before do
        create(:survey_item_response,  survey_item: student_survey_item, school:,
                                       academic_year:, likert_score: 4)
      end

      it_behaves_like 'measure_name'

      it 'returns the correct color' do
        expect(student_presenter.bar_color).to eq 'fill-approval'
      end

      it 'returns a bar width equal to the proportionate approval zone width' do
        expect(student_presenter.bar_height_percentage).to be_within(0.01).of(0)
      end

      it 'returns an x-offset of 60%' do
        expect(student_presenter.y_offset).to be_within(0.01).of(34)
      end
    end

    context 'when the score is in the Growth zone' do
      before do
        create(:survey_item_response,  survey_item: student_survey_item, school:,
                                       academic_year:, likert_score: 3)
      end

      it_behaves_like 'measure_name'

      it 'returns the correct color' do
        expect(student_presenter.bar_color).to eq 'fill-growth'
      end

      it 'returns a bar width equal to the proportionate growth zone width' do
        expect(student_presenter.bar_height_percentage).to be_within(0.01).of(17)
      end

      context 'in order to achieve the visual effect' do
        it 'returns an x-offset equal to 60% minus the bar width' do
          expect(student_presenter.y_offset).to eq 34
        end
      end
    end

    context 'when the score is in the Watch zone' do
      before do
        create(:survey_item_response,  survey_item: student_survey_item, school:,
                                       academic_year:, likert_score: 2)
      end

      it_behaves_like 'measure_name'

      it 'returns the correct color' do
        expect(student_presenter.bar_color).to eq 'fill-watch'
      end

      it 'returns a bar width equal to the proportionate watch zone width plus the growth zone width' do
        expect(student_presenter.bar_height_percentage).to eq 34
      end

      context 'in order to achieve the visual effect' do
        it 'returns an x-offset equal to 60% minus the bar width' do
          expect(student_presenter.y_offset).to eq 34
        end
      end
    end

    context 'when the score is in the Warning zone' do
      before do
        create(:survey_item_response,  survey_item: student_survey_item, school:,
                                       academic_year:, likert_score: 1)
      end

      it_behaves_like 'measure_name'

      it 'returns the correct color' do
        expect(student_presenter.bar_color).to eq 'fill-warning'
      end

      it 'returns a bar width equal to the proportionate warning zone width plus the watch & growth zone widths' do
        expect(student_presenter.bar_height_percentage).to eq 51
      end

      context 'in order to achieve the visual effect' do
        it 'returns an y-offset equal to 60% minus the bar width' do
          expect(student_presenter.y_offset).to eq 34
        end
      end
    end

    context 'when there are insufficient responses to calculate a score' do
      it 'indicates it should show the insufficient data message' do
        expect(student_presenter.show_insufficient_data_message?).to eq true
      end
    end
    context 'when there are enough responses to calculate a score' do
      before do
        create(:survey_item_response,  survey_item: student_survey_item, school:,
                                       academic_year:)
      end
      it 'indicates it should show the insufficient data message' do
        expect(student_presenter.show_insufficient_data_message?).to eq false
      end
    end
  end

  context 'when the measure is based on teacher survey items' do
    context 'when there are insufficient responses to calculate a score' do
      it 'indicates it should show the insufficient data message' do
        expect(teacher_presenter.show_insufficient_data_message?).to eq true
      end
    end
    context 'when there are enough responses to calculate a score' do
      before do
        create(:survey_item_response,  survey_item: teacher_survey_item, school:,
                                       academic_year:)
      end

      it 'indicates it should show the insufficient data message' do
        expect(teacher_presenter.show_insufficient_data_message?).to eq false
      end
    end
  end
end
