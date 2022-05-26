require 'rails_helper'

describe GroupedBarColumnPresenter do
  let(:watch_low_benchmark) { 2.9 }
  let(:growth_low_benchmark) { 3.1 }
  let(:approval_low_benchmark) { 3.6 }
  let(:ideal_low_benchmark) { 3.8 }

  let(:measure_with_student_survey_items) do
    measure = create(
      :measure,
      name: 'Some Title'
    )
    scale = create(:scale, measure:)

    create(:student_survey_item, scale:,
                                 watch_low_benchmark:,
                                 growth_low_benchmark:,
                                 approval_low_benchmark:,
                                 ideal_low_benchmark:)

    measure
  end

  let(:measure_with_teacher_survey_items) do
    measure = create(
      :measure,
      name: 'Some Title'
    )
    scale = create(:scale, measure:)

    create(:teacher_survey_item, scale:,
                                 watch_low_benchmark:,
                                 growth_low_benchmark:,
                                 approval_low_benchmark:,
                                 ideal_low_benchmark:)

    measure
  end
  let(:measure_without_admin_data_items) do
    create(
      :measure,
      name: 'Some Title'
    )
  end

  let(:student_presenter) do
    GroupedBarColumnPresenter.new measure: measure_with_student_survey_items, score:, position: 1, type: :student
  end

  let(:teacher_presenter) do
    GroupedBarColumnPresenter.new measure: measure_with_teacher_survey_items, score:, position: 1, type: :teacher
  end

  shared_examples_for 'measure_name' do
    it 'returns the measure name' do
      expect(student_presenter.measure_name).to eq 'Some Title'
    end
  end

  context 'when a measure is based on student survey items' do
    context 'when the score is in the Ideal zone' do
      let(:score) { Score.new(4.4, true, true) }

      it_behaves_like 'measure_name'

      it 'returns the correct color' do
        expect(student_presenter.bar_color).to eq 'fill-ideal'
      end

      it 'returns a bar width equal to the approval zone width plus the proportionate ideal zone width' do
        expect(student_presenter.bar_height_percentage).to be_within(0.01).of(25.5)
      end

      it 'returns a y_offset equal to the ' do
        expect(student_presenter.y_offset).to be_within(0.01).of(8.5)
      end
    end

    context 'when the score is in the Approval zone' do
      let(:score) { Score.new(3.7, true, true) }

      it_behaves_like 'measure_name'

      it 'returns the correct color' do
        expect(student_presenter.bar_color).to eq 'fill-approval'
      end

      it 'returns a bar width equal to the proportionate approval zone width' do
        expect(student_presenter.bar_height_percentage).to be_within(0.01).of(8.5)
      end

      it 'returns an x-offset of 60%' do
        expect(student_presenter.y_offset).to be_within(0.01).of(25.5)
      end
    end

    context 'when the score is in the Growth zone' do
      let(:score) { Score.new(3.2, true, true) }

      it_behaves_like 'measure_name'

      it 'returns the correct color' do
        expect(student_presenter.bar_color).to eq 'fill-growth'
      end

      it 'returns a bar width equal to the proportionate growth zone width' do
        expect(student_presenter.bar_height_percentage).to be_within(0.01).of(13.59)
      end

      context 'in order to achieve the visual effect' do
        it 'returns an x-offset equal to 60% minus the bar width' do
          expect(student_presenter.y_offset).to eq 34
        end
      end
    end

    context 'when the score is in the Watch zone' do
      let(:score) { Score.new(2.9, true, true) }

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
      let(:score) { Score.new(1.0, true, true) }

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
      let(:score) { Score.new(nil, true, false) }

      it 'indicates it should show the insufficient data message' do
        expect(student_presenter.show_insufficient_data_message?).to eq true
      end
    end
    context 'when there are enough responses to calculate a score' do
      let(:score) { Score.new(nil, true, true) }

      it 'indicates it should show the insufficient data message' do
        expect(student_presenter.show_insufficient_data_message?).to eq false
      end
    end
  end
  context 'when the presenter type is student but the measure is not based on student surveys' do
    let(:score) { Score.new(nil, false, false) }
    let(:student_presenter) do
      GroupedBarColumnPresenter.new measure: measure_without_admin_data_items, score:, position: 1, type: :student
    end
    it 'indecates it should show the irrelevancy message' do
      expect(student_presenter.show_irrelevancy_message?).to be true
    end
  end

  context 'when the measure is based on teacher survey items' do
    context 'when there are insufficient responses to calculate a score' do
      let(:score) { Score.new(nil, false, true) }

      it 'indicates it should show the insufficient data message' do
        expect(teacher_presenter.show_insufficient_data_message?).to eq true
      end
    end
    context 'when there are enough responses to calculate a score' do
      let(:score) { Score.new(nil, true, true) }

      it 'indicates it should show the insufficient data message' do
        expect(teacher_presenter.show_insufficient_data_message?).to eq false
      end
    end
    context 'when the presenter type is teacher but the measure is not based on teacher surveys' do
      let(:score) { Score.new(nil, false, false) }
      let(:teacher_presenter) do
        GroupedBarColumnPresenter.new measure: measure_without_admin_data_items, score:, position: 1, type: :teacher
      end
      it 'indecates it should show the irrelevancy message' do
        expect(teacher_presenter.show_irrelevancy_message?).to be true
      end
    end
  end
end
