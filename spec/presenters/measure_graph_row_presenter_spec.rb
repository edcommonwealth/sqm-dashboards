require 'rails_helper'

RSpec.describe MeasureGraphRowPresenter do

  let(:watch_low_benchmark) { 2.9 }
  let(:growth_low_benchmark) { 3.1 }
  let(:approval_low_benchmark) { 3.6 }
  let(:ideal_low_benchmark) { 3.8 }

  let(:measure) {
    Measure.new(
      name: 'Some Title',
      watch_low_benchmark: watch_low_benchmark,
      growth_low_benchmark: growth_low_benchmark,
      approval_low_benchmark: approval_low_benchmark,
      ideal_low_benchmark: ideal_low_benchmark
    )
  }

  let(:presenter) {
    MeasureGraphRowPresenter.new measure: measure, score: score
  }

  shared_examples_for 'measure_name' do
    it 'returns the measure name' do
      expect(presenter.measure_name).to eq 'Some Title'
    end
  end

  context('when the score is in the Ideal zone') do
    let(:score) { 4.4 }

    it_behaves_like 'measure_name'

    it 'returns the correct color' do
      expect(presenter.bar_color).to eq "fill-ideal"
    end

    it 'returns a bar width equal to the approval zone width plus the proportionate ideal zone width' do
      expect(presenter.bar_width).to eq "30.0%"
    end

    it 'returns an x-offset of 60%' do
      expect(presenter.x_offset).to eq "60%"
    end
  end

  context('when the score is in the Approval zone') do
    let(:score) { 3.7 }

    it_behaves_like 'measure_name'

    it "returns the correct color" do
      expect(presenter.bar_color).to eq "fill-approval"
    end

    it 'returns a bar width equal to the proportionate approval zone width' do
      expect(presenter.bar_width).to eq "10.0%"
    end

    it 'returns an x-offset of 60%' do
      expect(presenter.x_offset).to eq "60%"
    end
  end

  context('when the score is in the Growth zone') do
    let(:score) { 3.2 }

    it_behaves_like 'measure_name'

    it "returns the correct color" do
      expect(presenter.bar_color).to eq "fill-growth"
    end

    it 'returns a bar width equal to the proportionate growth zone width' do
      expect(presenter.bar_width).to eq "16.0%"
    end

    context 'in order to achieve the visual effect' do
      it 'returns an x-offset equal to 60% minus the bar width' do
        expect(presenter.x_offset).to eq "44.0%"
      end
    end
  end

  context('when the score is in the Watch zone') do
    let(:score) { 2.9 }

    it_behaves_like 'measure_name'

    it "returns the correct color" do
      expect(presenter.bar_color).to eq "fill-watch"
    end

    it 'returns a bar width equal to the proportionate watch zone width plus the growth zone width' do
      expect(presenter.bar_width).to eq "40.0%"
    end

    context 'in order to achieve the visual effect' do
      it 'returns an x-offset equal to 60% minus the bar width' do
        expect(presenter.x_offset).to eq "20.0%"
      end
    end
  end

  context('when the score is in the Warning zone') do
    let(:score) { 1.0 }

    it_behaves_like 'measure_name'

    it "returns the correct color" do
      expect(presenter.bar_color).to eq "fill-warning"
    end

    it 'returns a bar width equal to the proportionate warning zone width plus the watch & growth zone widths' do
      expect(presenter.bar_width).to eq "60.0%"
    end

    context 'in order to achieve the visual effect' do
      it 'returns an x-offset equal to 60% minus the bar width' do
        expect(presenter.x_offset).to eq "0.0%"
      end
    end
  end

  context 'sorting scores' do
    it 'selects a shorter bar width before a longer bar' do
      this_presenter = MeasureGraphRowPresenter.new measure: measure, score: 3.7
      other_presenter = MeasureGraphRowPresenter.new measure: measure, score: 4.4
      expect(this_presenter <=> other_presenter).to be < 0
    end

    it 'selects a warning bar before a ideal bar' do
      this_presenter = MeasureGraphRowPresenter.new measure: measure, score: 1.0
      other_presenter = MeasureGraphRowPresenter.new measure: measure, score: 5.0
      expect(this_presenter <=> other_presenter).to be < 0
    end

    it 'selects an ideal bar after a warning bar' do
      this_presenter = MeasureGraphRowPresenter.new measure: measure, score: 4.4
      other_presenter = MeasureGraphRowPresenter.new measure: measure, score: 1.0
      expect(this_presenter <=> other_presenter).to be > 0
    end
  end
end
