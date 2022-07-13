# frozen_string_literal: true

class CategoriesController < SqmApplicationController
  before_action :response_rate_timestamp, only: [:index]
  helper GaugeHelper

  def show
    @categories = Category.sorted.map { |category| CategoryPresenter.new(category:) }

    @category = CategoryPresenter.new(category: Category.find_by_slug(params[:id]))
  end

  private

  def response_rate_timestamp
    @response_rate_timestamp = begin
      rate = ResponseRate.where(school: @school,
                                academic_year: @academic_year).order(updated_at: :DESC).first || Today.new

      rate.updated_at
    end
    @response_rate_timestamp
  end
end
