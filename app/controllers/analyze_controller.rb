# frozen_string_literal: true

class AnalyzeController < SqmApplicationController
  def index
    @presenter = Analyze::Presenter.new(params:, school: @school, academic_year: @academic_year)
    @background ||= Analyze::BackgroundPresenter.new(num_of_columns: @presenter.graph.columns.count)
    @academic_year = @presenter.selected_academic_years&.first || AcademicYear.last
  end
end
