class AnalyzeController < SqmApplicationController
  def index
    @category ||= Category.find_by_category_id(params[:category])
    @category ||= Category.order(:category_id).first
    @categories = Category.all.order(:category_id)

    @subcategories = @category.subcategories.order(:subcategory_id)
    @subcategory ||= Subcategory.find_by_subcategory_id(params[:subcategory])
    @subcategory ||= @subcategories.first

    @measures = @subcategory.measures.order(:measure_id).includes(%i[scales admin_data_items subcategory])

    @available_academic_years = AcademicYear.order(:range).all
    @academic_year_params = params[:academic_years].split(',') if params[:academic_years]
    @selected_academic_years = []
    if @academic_year_params.present?
      @academic_year_params.each do |year|
        @selected_academic_years << AcademicYear.find_by_range(year)
      end
    else
      @selected_academic_years = [@academic_year]
    end
  end
end
