require 'rails_helper'

describe GaugePresenter do
  let(:scale) do
    Scale.new(
      watch_low_benchmark: 1.5,
      growth_low_benchmark: 2.5,
      approval_low_benchmark: 3.5,
      ideal_low_benchmark: 4.5
    )
  end
  let(:score) { 3 }

  let(:gauge_presenter) { GaugePresenter.new(scale: scale, score: score) }

  it 'returns the key benchmark percentage for the gauge' do
    expect(gauge_presenter.key_benchmark_percentage).to eq 0.625
  end

  context 'when the given score is in the Warning zone for the given scale' do
    let(:score) { 1 }

    it 'returns the title of the zone' do
      expect(gauge_presenter.title).to eq 'Warning'
    end

    it 'returns the color class for the gauge' do
      expect(gauge_presenter.color_class).to eq 'fill-warning'
    end

    it 'returns the score percentage for the gauge' do
      expect(gauge_presenter.score_percentage).to eq 0.0
    end
  end

  context 'when the given score is in the Watch zone for the given scale' do
    let(:score) { 2 }

    it 'returns the title of the zone' do
      expect(gauge_presenter.title).to eq 'Watch'
    end

    it 'returns the color class for the gauge' do
      expect(gauge_presenter.color_class).to eq 'fill-watch'
    end

    it 'returns the score percentage for the gauge' do
      expect(gauge_presenter.score_percentage).to eq 0.25
    end
  end

  context 'when the given score is in the Growth zone for the given scale' do
    let(:score) { 3 }

    it 'returns the title of the zone' do
      expect(gauge_presenter.title).to eq 'Growth'
    end

    it 'returns the color class for the gauge' do
      expect(gauge_presenter.color_class).to eq 'fill-growth'
    end

    it 'returns the score percentage for the gauge' do
      expect(gauge_presenter.score_percentage).to eq 0.5
    end
  end

  context 'when the given score is in the Approval zone for the given scale' do
    let(:score) { 4 }

    it 'returns the title of the zone' do
      expect(gauge_presenter.title).to eq 'Approval'
    end

    it 'returns the color class for the gauge' do
      expect(gauge_presenter.color_class).to eq 'fill-approval'
    end

    it 'returns the score percentage for the gauge' do
      expect(gauge_presenter.score_percentage).to eq 0.75
    end
  end

  context 'when the given score is in the Ideal zone for the given scale' do
    let(:score) { 5 }

    it 'returns the title of the zone' do
      expect(gauge_presenter.title).to eq 'Ideal'
    end

    it 'returns the color class for the gauge' do
      expect(gauge_presenter.color_class).to eq 'fill-ideal'
    end

    it 'returns the score percentage for the gauge' do
      expect(gauge_presenter.score_percentage).to eq 1.0
    end
  end

  context 'when there are no benchmarks or score for the gauge' do
    let(:scale) do
      Scale.new(
        watch_low_benchmark: nil,
        growth_low_benchmark: nil,
        approval_low_benchmark: nil,
        ideal_low_benchmark: nil
      )
    end
    let(:score) { nil }

    it 'returns the title of the zone' do
      expect(gauge_presenter.title).to eq 'Insufficient Data'
    end

    it 'returns the color class for the gauge' do
      expect(gauge_presenter.color_class).to eq 'fill-insufficient_data'
    end

    it 'returns the score percentage for the gauge' do
      expect(gauge_presenter.score_percentage).to be_nil
    end
  end
end
