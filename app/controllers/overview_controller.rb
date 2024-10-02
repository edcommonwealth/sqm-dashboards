# frozen_string_literal: true

class OverviewController < SqmApplicationController
  helper VarianceHelper

  def index
    @page = if params[:view] == "student" || params[:view].nil?
              Overview::OverviewPresenter.new(params:, school: @school, academic_year: @academic_year)
            else
              Overview::ParentOverviewPresenter.new(params:, school: @school, academic_year: @academic_year)
            end

    @has_empty_dataset = @page.empty_dataset?
    @variance_chart_row_presenters = @page.variance_chart_row_presenters
    @category_presenters = @page.category_presenters
    @student_response_rate_presenter = @page.student_response_rate_presenter
    @teacher_response_rate_presenter = @page.teacher_response_rate_presenter
    @parent_response_rate_presenter = @page.parent_response_rate_presenter
  end
end

