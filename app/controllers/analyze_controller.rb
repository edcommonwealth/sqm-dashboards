# frozen_string_literal: true

class AnalyzeController < SqmApplicationController
  before_action :assign_categories, :assign_subcategories, :assign_measures, :assign_academic_years,
                :response_rate_timestamp, only: [:index]
  def index; end

  private

  def assign_categories
    @category ||= Category.find_by_category_id(params[:category])
    @category ||= Category.order(:category_id).first
    @categories = Category.all.order(:category_id)
  end

  def assign_subcategories
    @subcategories = @category.subcategories.order(:subcategory_id)
    @subcategory ||= Subcategory.find_by_subcategory_id(params[:subcategory])
    @subcategory ||= @subcategories.first
  end

  def assign_measures
    @measures = @subcategory.measures.order(:measure_id).includes(%i[admin_data_items subcategory])
  end

  def assign_academic_years
    @available_academic_years = AcademicYear.order(:range).all
    year_params = params[:academic_years]
    @academic_year_params = year_params.split(',') if year_params
    @selected_academic_years = []
    @academic_year_params ||= []
    @academic_year_params.each do |year|
      @selected_academic_years << AcademicYear.find_by_range(year)
    end
  end

  def response_rate_timestamp
    @response_rate_timestamp = begin
      academic_year = @selected_academic_years.last
      academic_year ||= @academic_year
      rate = ResponseRate.where(school: @school,
                                academic_year:).order(updated_at: :DESC).first || Today.new

      rate.updated_at
    end
    @response_rate_timestamp
  end
end
