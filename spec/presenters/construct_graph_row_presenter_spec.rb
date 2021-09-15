require 'rails_helper'

RSpec.describe "construct graph row presenter" do

  let(:watch_low_benchmark) { 2.9 }
  let(:growth_low_benchmark) { 3.1 }
  let(:approval_low_benchmark) { 3.6 }
  let(:ideal_low_benchmark) { 3.8 }

  let(:construct) {
    Construct.new(
      name: 'Some Title',
      watch_low_benchmark: watch_low_benchmark,
      growth_low_benchmark: growth_low_benchmark,
      approval_low_benchmark: approval_low_benchmark,
      ideal_low_benchmark: ideal_low_benchmark
    )
  }

  let(:presenter) {
    ConstructGraphRowPresenter.new construct: construct, score: score
  }

  shared_examples_for 'construct_title' do
    it('returns the construct title') do
      expect(presenter.construct_name).to eq 'Some Title'
    end
  end

  context('when the score is in the Ideal zone') do
    let(:score) { 4.4 }

    it_behaves_like 'construct_title'

    it('returns the correct color') do
      expect(presenter.bar_color).to eq ConstructGraphParameters::ZoneColor::IDEAL
    end

    it('returns a bar width equal to the approval zone width plus the proportionate ideal zone width') do
      expect(presenter.bar_width).to eq 324
    end

    it('returns an x-offset of 0') do
      expect(presenter.x_offset).to eq 0
    end
  end

  context('when the score is in the Approval zone') do
    let(:score) { 3.7 }

    it_behaves_like 'construct_title'

    it("returns the correct color") do
      expect(presenter.bar_color).to eq ConstructGraphParameters::ZoneColor::APPROVAL
    end

    it('returns a bar width equal to the proportionate approval zone width') do
      expect(presenter.bar_width).to eq 108
    end

    it('returns an x-offset of 0') do
      expect(presenter.x_offset).to eq 0
    end
  end

  context('when the score is in the Growth zone') do
    let(:score) { 3.2 }

    it_behaves_like 'construct_title'

    it("returns the correct color") do
      expect(presenter.bar_color).to eq ConstructGraphParameters::ZoneColor::GROWTH
    end

    it('returns a bar width equal to the proportionate growth zone width') do
      expect(presenter.bar_width).to eq 29
    end

    it('returns an x-offset equal to the bar width') do
      expect(presenter.x_offset).to eq 29
    end
  end

  context('when the score is in the Watch zone') do
    let(:score) { 3.0 }

    it_behaves_like 'construct_title'

    it("returns the correct color") do
      expect(presenter.bar_color).to eq ConstructGraphParameters::ZoneColor::WATCH
    end

    it('returns a bar width equal to the proportionate watch zone width plus the growth zone width') do
      expect(presenter.bar_width).to eq 216
    end

    it('returns an x-offset equal to the bar width') do
      expect(presenter.x_offset).to be > 0
    end
  end

  context('when the score is in the Warning zone') do
    let(:score) { 2.8 }

    it_behaves_like 'construct_title'

    it("returns the correct color") do
      expect(presenter.bar_color).to eq ConstructGraphParameters::ZoneColor::WARNING
    end

    it('returns a bar width equal to the proportionate warning zone width plus the watch & growth zone widths') do
      expect(presenter.bar_width).to eq 424
    end

    it('returns an x-offset equal to the bar width') do
      expect(presenter.x_offset).to eq 424
    end
  end
end
