require 'rails_helper'

RSpec.describe Score, type: :model do
  let(:zones) do
    Zones.new(watch_low_benchmark: 1.5, growth_low_benchmark: 2, approval_low_benchmark: 3,
              ideal_low_benchmark: 4)
  end

  let(:warning) do
    zones.warning_zone
  end
  let(:watch) do
    zones.watch_zone
  end
  let(:growth) do
    zones.growth_zone
  end
  let(:approval) do
    zones.approval_zone
  end
  let(:ideal) do
    zones.ideal_zone
  end

  context '.in_zone?' do
    it('returns true if the score is in the warning zone') do
      score = Score.new(average: 1)
      expect(score.in_zone?(zone: warning)).to eq true
      expect(score.in_zone?(zone: watch)).to eq false
      expect(score.in_zone?(zone: growth)).to eq false
      expect(score.in_zone?(zone: approval)).to eq false
      expect(score.in_zone?(zone: ideal)).to eq false
    end

    it('returns true if the score is in the watch zone') do
      score = Score.new(average: 1.5)
      expect(score.in_zone?(zone: warning)).to eq true
      expect(score.in_zone?(zone: watch)).to eq true
      expect(score.in_zone?(zone: growth)).to eq false
      expect(score.in_zone?(zone: approval)).to eq false
      expect(score.in_zone?(zone: ideal)).to eq false
    end
  end
  context '.blank?' do
    it 'returns true if the average is nil zero or not a number' do
      expect(Score.new(average: 0).blank?).to eq true
      expect(Score.new(average: nil).blank?).to eq true
      nan = Float::NAN
      expect(Score.new(average: nan).blank?).to eq true
    end

    it 'returns false if the average is a non-zero float' do
      expect(Score.new(average: 1).blank?).to eq false
      expect(Score.new(average: 0.1).blank?).to eq false
      expect(Score.new(average: -0.1).blank?).to eq false
    end
  end
end
