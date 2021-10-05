require 'rails_helper'

describe SubcategoryCardPresenter do
  let(:scale) do
    Scale.new(
      watch_low_benchmark: 1.5,
      growth_low_benchmark: 2.5,
      approval_low_benchmark: 3.5,
      ideal_low_benchmark: 4.5,
    )
  end

  let(:subcategory_card_presenter) { SubcategoryCardPresenter.new(scale: scale, score: score)}

  context 'when the given score is in the Warning zone for the given scale' do
    let(:score) { 1 }
    it 'returns the abbreviation of the zone' do
      expect(subcategory_card_presenter.abbreviation).to eq "Wr"
    end

    it 'returns the color class of the zone' do
      expect(subcategory_card_presenter.color).to eq "fill-warning"
    end
  end

  context 'when the given score is in the Watch zone for the given scale' do
    let(:score) { 2 }
    it 'returns the abbreviation of the zone' do
      expect(subcategory_card_presenter.abbreviation).to eq "Wa"
    end

    it 'returns the color class of the zone' do
      expect(subcategory_card_presenter.color).to eq "fill-watch"
    end
  end

  context 'when the given score is in the Growth zone for the given scale' do
    let(:score) { 3 }
    it 'returns the abbreviation of the zone' do
      expect(subcategory_card_presenter.abbreviation).to eq "G"
    end

    it 'returns the color class of the zone' do
      expect(subcategory_card_presenter.color).to eq "fill-growth"
    end
  end

  context 'when the given score is in the Approval zone for the given scale' do
    let(:score) { 4 }
    it 'returns the abbreviation of the zone' do
      expect(subcategory_card_presenter.abbreviation).to eq "A"
    end

    it 'returns the color class of the zone' do
      expect(subcategory_card_presenter.color).to eq "fill-approval"
    end
  end

  context 'when the given score is in the Ideal zone for the given scale' do
    let(:score) { 5 }
    it 'returns the abbreviation of the zone' do
      expect(subcategory_card_presenter.abbreviation).to eq "I"
    end

    it 'returns the color class of the zone' do
      expect(subcategory_card_presenter.color).to eq "fill-ideal"
    end
  end
end
