# frozen_string_literal: true

class AnalyzeController < SqmApplicationController
  def index
    assign_categories
    assign_subcategories
    assign_measures
    assign_academic_years
  end

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
    @measures = @subcategory.measures.order(:measure_id).includes(%i[subcategory])
  end

  def assign_academic_years
    @available_academic_years = AcademicYear.order(:range).all
    @academic_year_params = params[:academic_years].split(',') if params[:academic_years]
    @selected_academic_years = []
    @academic_year_params ||= []
    @academic_year_params.each do |year|
      @selected_academic_years << AcademicYear.find_by_range(year)
    end
  end
end
