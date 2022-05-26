require 'rails_helper'

describe GroupedBarColumnPresenter do
  let(:watch_low_benchmark) { 2.9 }
  let(:growth_low_benchmark) { 3.1 }
  let(:approval_low_benchmark) { 3.6 }
  let(:ideal_low_benchmark) { 3.8 }

  let(:measure) do
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

  let(:measure_without_admin_data_items) do
    create(
      :measure,
      name: 'Some Title'
    )
  end

  let(:presenter) do
    GroupedBarColumnPresenter.new measure:, score:, position: 1, type: :all
  end

  shared_examples_for 'measure_name' do
    it 'returns the measure name' do
      expect(presenter.measure_name).to eq 'Some Title'
    end
  end

  context 'when the score is in the Ideal zone' do
    let(:score) { Score.new(4.4, true, true) }

    it_behaves_like 'measure_name'

    it 'returns the correct color' do
      expect(presenter.bar_color).to eq 'fill-ideal'
    end

    it 'returns a bar width equal to the approval zone width plus the proportionate ideal zone width' do
      expect(presenter.bar_height_percentage).to be_within(0.01).of(25.5)
    end

    it 'returns a y_offset equal to the ' do
      expect(presenter.y_offset).to be_within(0.01).of(8.5)
    end
  end

  context 'when the score is in the Approval zone' do
    let(:score) { Score.new(3.7, true, true) }

    it_behaves_like 'measure_name'

    it 'returns the correct color' do
      expect(presenter.bar_color).to eq 'fill-approval'
    end

    it 'returns a bar width equal to the proportionate approval zone width' do
      expect(presenter.bar_height_percentage).to be_within(0.01).of(8.5)
    end

    it 'returns an x-offset of 60%' do
      expect(presenter.y_offset).to be_within(0.01).of(25.5)
    end
  end

  context 'when the score is in the Growth zone' do
    let(:score) { Score.new(3.2, true, true) }

    it_behaves_like 'measure_name'

    it 'returns the correct color' do
      expect(presenter.bar_color).to eq 'fill-growth'
    end

    it 'returns a bar width equal to the proportionate growth zone width' do
      expect(presenter.bar_height_percentage).to be_within(0.01).of(13.59)
    end

    context 'in order to achieve the visual effect' do
      it 'returns an x-offset equal to 60% minus the bar width' do
        expect(presenter.y_offset).to eq 34
      end
    end
  end

  context 'when the score is in the Watch zone' do
    let(:score) { Score.new(2.9, true, true) }

    it_behaves_like 'measure_name'

    it 'returns the correct color' do
      expect(presenter.bar_color).to eq 'fill-watch'
    end

    it 'returns a bar width equal to the proportionate watch zone width plus the growth zone width' do
      expect(presenter.bar_height_percentage).to eq 34
    end

    context 'in order to achieve the visual effect' do
      it 'returns an x-offset equal to 60% minus the bar width' do
        expect(presenter.y_offset).to eq 34
      end
    end
  end

  context 'when the score is in the Warning zone' do
    let(:score) { Score.new(1.0, true, true) }

    it_behaves_like 'measure_name'

    it 'returns the correct color' do
      expect(presenter.bar_color).to eq 'fill-warning'
    end

    it 'returns a bar width equal to the proportionate warning zone width plus the watch & growth zone widths' do
      expect(presenter.bar_height_percentage).to eq 51
    end

    context 'in order to achieve the visual effect' do
      it 'returns an y-offset equal to 60% minus the bar width' do
        expect(presenter.y_offset).to eq 34
      end
    end
  end

  # context 'when a measure contains teacher survey items' do
  #   before :each do
  #     scale = create(:scale, measure:)
  #     create :teacher_survey_item, scale:
  #   end

  #   context 'when there are insufficient teacher survey item responses' do
  #     let(:score) { Score.new(nil, false, true) }
  #     it 'shows a message saying there are insufficient responses' do
  #       expect(presenter.insufficient_teacher_responses?).to be true
  #     end
  #   end

  #   context 'when there are sufficient teacher survey item responses' do
  #     let(:score) { Score.new(nil, true, true) }
  #     it 'does not show a partial data indicator' do
  #       expect(presenter.show_teacher_inapplicability_message?).to be true
  #     end
  #   end
  # end

  # context 'when a measure does not contain teacher survey items' do
  #   context 'when there are insufficient teacher survey item responses' do
  #     let(:score) { Score.new(nil, false, true) }
  #     it 'shows a message saying the measure is not based on teacher survey items' do
  #       expect(presenter.show_teacher_inapplicability_message?).to be false
  #     end
  #   end
  # end

  # context 'when a measure contains student survey items' do
  #   before :each do
  #     scale = create(:scale, measure:)
  #     create :student_survey_item, scale:
  #   end

  #   context 'when there are insufficient student survey item responses' do
  #     let(:score) { Score.new(nil, true, false) }
  #     it 'shows a partial data indicator' do
  #       expect(presenter.show_student_inapplicability_message?).to be true
  #     end
  #   end
  #   context 'when there are sufficient student survey item responses' do
  #     let(:score) { Score.new(nil, true, true) }
  #     it 'shows a partial data indicator' do
  #       expect(presenter.show_student_inapplicability_message?).to be true
  #     end
  #   end
  # end
end
