# frozen_string_literal: true

class AnalyzeController < SqmApplicationController
  def index
    @presenter = Analyze::Presenter.new(params:, school: @school, academic_year: @academic_year)
    @background ||= BackgroundPresenter.new(num_of_columns: @presenter.graph.columns.count)
  end
end
