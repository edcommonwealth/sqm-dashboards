require 'rails_helper'

describe SubcategoryCardPresenter do
  let(:zones) do
    Zones.new(
      watch_low_benchmark: 1.5,
      growth_low_benchmark: 2.5,
      approval_low_benchmark: 3.5,
      ideal_low_benchmark: 4.5
    )
  end

  let(:subcategory_card_presenter) { SubcategoryCardPresenter.new(subcategory: Subcategory.new(name: 'A subcategory'), zones:, score:) }

  context 'when the given score is in the Warning zone for the given scale' do
    let(:score) { 1 }

    it 'returns the icon that represents the zone' do
      expect(subcategory_card_presenter.harvey_ball_icon).to eq 'warning-harvey-ball'
    end

    it 'returns the color class of the zone' do
      expect(subcategory_card_presenter.color).to eq 'warning'
    end
  end

  context 'when the given score is in the Watch zone for the given scale' do
    let(:score) { 2 }

    it 'returns the icon that represents the zone' do
      expect(subcategory_card_presenter.harvey_ball_icon).to eq 'watch-harvey-ball'
    end

    it 'returns the color class of the zone' do
      expect(subcategory_card_presenter.color).to eq 'watch'
    end
  end

  context 'when the given score is in the Growth zone for the given scale' do
    let(:score) { 3 }

    it 'returns the icon that represents the zone' do
      expect(subcategory_card_presenter.harvey_ball_icon).to eq 'growth-harvey-ball'
    end

    it 'returns the color class of the zone' do
      expect(subcategory_card_presenter.color).to eq 'growth'
    end
  end

  context 'when the given score is in the Approval zone for the given scale' do
    let(:score) { 4 }

    it 'returns the icon that represents the zone' do
      expect(subcategory_card_presenter.harvey_ball_icon).to eq 'approval-harvey-ball'
    end

    it 'returns the color class of the zone' do
      expect(subcategory_card_presenter.color).to eq 'approval'
    end
  end

  context 'when the given score is in the Ideal zone for the given scale' do
    let(:score) { 5 }

    it 'returns the icon that represents the zone' do
      expect(subcategory_card_presenter.harvey_ball_icon).to eq 'ideal-harvey-ball'
    end

    it 'returns the color class of the zone' do
      expect(subcategory_card_presenter.color).to eq 'ideal'
    end
  end

  context 'when the given score is invalid for the given scale' do
    let(:score) { 0 }

    it 'returns the icon that represents the zone' do
      expect(subcategory_card_presenter.harvey_ball_icon).to eq 'insufficient_data-harvey-ball'
    end

    it 'reports that there is insufficient data' do
      expect(subcategory_card_presenter.insufficient_data?).to be true
    end
  end
end
