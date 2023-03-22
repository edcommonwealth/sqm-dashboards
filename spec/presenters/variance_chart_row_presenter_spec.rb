require "rails_helper"

describe VarianceChartRowPresenter do
  let(:watch_low_benchmark) { 2.9 }
  let(:growth_low_benchmark) { 3.1 }
  let(:approval_low_benchmark) { 3.6 }
  let(:ideal_low_benchmark) { 3.8 }

  let(:measure) do
    measure = create(
      :measure,
      name: "Some Title"
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
      name: "Some Title"
    )
  end

  let(:presenter) do
    VarianceChartRowPresenter.new measure:, score:
  end

  shared_examples_for "measure_name" do
    it "returns the measure name" do
      expect(presenter.measure_name).to eq "Some Title"
    end
  end

  context "when the score is in the Ideal zone" do
    let(:score) { Score.new(average: 4.4, meets_teacher_threshold: true, meets_student_threshold: true) }

    it_behaves_like "measure_name"

    it "returns the correct color" do
      expect(presenter.bar_color).to eq "fill-ideal"
    end

    it "returns a bar width equal to the approval zone width plus the proportionate ideal zone width" do
      expect(presenter.bar_width).to eq "30.0%"
    end

    it "returns an x-offset of 60%" do
      expect(presenter.x_offset).to eq "60%"
    end
  end

  context "when the score is in the Approval zone" do
    let(:score) { Score.new(average: 3.7, meets_teacher_threshold: true, meets_student_threshold: true) }

    it_behaves_like "measure_name"

    it "returns the correct color" do
      expect(presenter.bar_color).to eq "fill-approval"
    end

    it "returns a bar width equal to the proportionate approval zone width" do
      expect(presenter.bar_width).to eq "10.0%"
    end

    it "returns an x-offset of 60%" do
      expect(presenter.x_offset).to eq "60%"
    end
  end

  context "when the score is in the Growth zone" do
    let(:score) { Score.new(average: 3.2, meets_teacher_threshold: true, meets_student_threshold: true) }

    it_behaves_like "measure_name"

    it "returns the correct color" do
      expect(presenter.bar_color).to eq "fill-growth"
    end

    it "returns a bar width equal to the proportionate growth zone width" do
      expect(presenter.bar_width).to eq "16.0%"
    end

    context "in order to achieve the visual effect" do
      it "returns an x-offset equal to 60% minus the bar width" do
        expect(presenter.x_offset).to eq "44.0%"
      end
    end
  end

  context "when the score is in the Watch zone" do
    let(:score) { Score.new(average: 2.9, meets_teacher_threshold: true, meets_student_threshold: true) }

    it_behaves_like "measure_name"

    it "returns the correct color" do
      expect(presenter.bar_color).to eq "fill-watch"
    end

    it "returns a bar width equal to the proportionate watch zone width plus the growth zone width" do
      expect(presenter.bar_width).to eq "40.0%"
    end

    context "in order to achieve the visual effect" do
      it "returns an x-offset equal to 60% minus the bar width" do
        expect(presenter.x_offset).to eq "20.0%"
      end
    end
  end

  context "when the score is in the Warning zone" do
    let(:score) { Score.new(average: 1.0, meets_teacher_threshold: true, meets_student_threshold: true) }

    it_behaves_like "measure_name"

    it "returns the correct color" do
      expect(presenter.bar_color).to eq "fill-warning"
    end

    it "returns a bar width equal to the proportionate warning zone width plus the watch & growth zone widths" do
      expect(presenter.bar_width).to eq "60.0%"
    end

    context "in order to achieve the visual effect" do
      it "returns an x-offset equal to 60% minus the bar width" do
        expect(presenter.x_offset).to eq "0.0%"
      end
    end
  end

  context "when a measure does not contain admin data items" do
    let(:score) { Score.new(average: nil, meets_teacher_threshold: false, meets_student_threshold: false) }

    it "it does not show a partial data indicator" do
      presenter_without_admin_data = VarianceChartRowPresenter.new measure: measure_without_admin_data_items,
        score: score
      expect(presenter_without_admin_data.show_partial_data_indicator?).to be false
    end
  end

  context "when a measure contains admin data items" do
    before :each do
    end

    let(:score) { Score.new(average: nil, meets_teacher_threshold: false, meets_student_threshold: false) }

    it "shows a partial data indicator" do
      measure_with_admin_data = create(
        :measure,
        name: "Some Title"
      )
      scale_with_admin_data = create(:scale, measure: measure_with_admin_data)
      create :admin_data_item,
        scale: scale_with_admin_data,
        watch_low_benchmark: watch_low_benchmark,
        growth_low_benchmark: growth_low_benchmark,
        approval_low_benchmark: approval_low_benchmark,
        ideal_low_benchmark: ideal_low_benchmark
      admin_data_presenter = VarianceChartRowPresenter.new measure: measure_with_admin_data,
        score: Score.new(
          average: 3.7, meets_teacher_threshold: true, meets_student_threshold: true
        )
      expect(admin_data_presenter.show_partial_data_indicator?).to be true
      expect(admin_data_presenter.partial_data_sources).to eq ["school data"]
    end
  end

  context "when a measure contains teacher survey items" do
    before :each do
      scale = create(:scale, measure:)
      create :teacher_survey_item, scale:
    end

    context "when there are insufficient teacher survey item responses" do
      let(:score) { Score.new(average: nil, meets_teacher_threshold: false, meets_student_threshold: true) }
      it "shows a partial data indicator" do
        expect(presenter.show_partial_data_indicator?).to be true
        expect(presenter.partial_data_sources).to eq ["teacher survey results"]
      end
    end

    context "when there are sufficient teacher survey item responses" do
      let(:score) { Score.new(average: nil, meets_teacher_threshold: true, meets_student_threshold: true) }
      it "does not show a partial data indicator" do
        expect(presenter.show_partial_data_indicator?).to be false
      end
    end
  end

  context "when a measure contains student survey items" do
    before :each do
      scale = create(:scale, measure:)
      create :student_survey_item, scale:
    end

    context "when there are insufficient student survey item responses" do
      let(:score) { Score.new(average: nil, meets_teacher_threshold: true, meets_student_threshold: false) }
      it "shows a partial data indicator" do
        expect(presenter.show_partial_data_indicator?).to be true
        expect(presenter.partial_data_sources).to eq ["student survey results"]
      end

      context "where there are also admin data items" do
        before :each do
          scale = create(:scale, measure:)
          create :admin_data_item, scale:
        end

        it "returns the sources for partial results of administrative data and student survey results" do
          expect(presenter.partial_data_sources).to eq ["student survey results", "school data"]
        end
      end
    end

    context "When there are sufficient student survey item responses" do
      let(:score) { Score.new(average: nil, meets_teacher_threshold: true, meets_student_threshold: true) }
      it "does not show a partial data indicator" do
        expect(presenter.show_partial_data_indicator?).to be false
      end
    end
  end

  context "sorting scores" do
    it "selects a longer bar before a shorter bar for measures in the approval/ideal zones" do
      scale_with_student_survey_items = create(:scale, measure:)
      create(:student_survey_item,
        scale: scale_with_student_survey_items,
        watch_low_benchmark:,
        growth_low_benchmark:,
        approval_low_benchmark:,
        ideal_low_benchmark:)
      approval_presenter = VarianceChartRowPresenter.new measure: measure, score: Score.new(average: 3.7, meets_teacher_threshold: true, meets_student_threshold: true)
      ideal_presenter = VarianceChartRowPresenter.new measure: measure, score: Score.new(average: 4.4, meets_teacher_threshold: true, meets_student_threshold: true)
      expect(ideal_presenter <=> approval_presenter).to be < 0
      expect([approval_presenter, ideal_presenter].sort).to eq [ideal_presenter, approval_presenter]
    end

    it "selects a warning bar below a ideal bar" do
      warning_presenter = VarianceChartRowPresenter.new measure: measure, score: Score.new(average: 1.0, meets_teacher_threshold: true, meets_student_threshold: true)
      ideal_presenter = VarianceChartRowPresenter.new measure: measure, score: Score.new(average: 5.0, meets_teacher_threshold: true, meets_student_threshold: true)
      expect(warning_presenter <=> ideal_presenter).to be > 0
      expect([warning_presenter, ideal_presenter].sort).to eq [ideal_presenter, warning_presenter]
    end
  end
end
