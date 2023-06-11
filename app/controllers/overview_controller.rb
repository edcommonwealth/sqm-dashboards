# frozen_string_literal: true

class OverviewController < SqmApplicationController
  before_action :check_empty_dataset, only: [:index]
  helper VarianceHelper

  def index
    @variance_chart_row_presenters = measures.map(&method(:presenter_for_measure))
    @category_presenters = Category.sorted.map { |category| CategoryPresenter.new(category:) }
  end

  private

  def presenter_for_measure(measure)
    score = measure.score(school: @school, academic_year: @academic_year)

    VarianceChartRowPresenter.new(measure:, score:)
  end

  def check_empty_dataset
    @has_empty_dataset = subcategories.none? do |subcategory|
      response_rate = subcategory.response_rate(school: @school, academic_year: @academic_year)
      response_rate.meets_student_threshold || response_rate.meets_teacher_threshold
    end
  end

  def measures
    @measures ||= Measure.all.includes(%i[scales admin_data_items category subcategory survey_items])
  end

  def subcategories
    @subcategories ||= Subcategory.all.includes(:measures)
  end
end
