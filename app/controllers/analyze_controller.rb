class AnalyzeController < SqmApplicationController
  def index
    @category ||= Category.find_by_category_id(params[:category_id])
    @category ||= Category.find_by_category_id(1)

    @subcategory ||= Subcategory.find_by_subcategory_id(params[:subcategory_id])
    @subcategory ||= Subcategory.find_by_subcategory_id('1A')

    @measure = @subcategory.measures.includes(%i[admin_data_items category])[0]
    @academic_year ||= AcademicYear.order('range DESC').first
  end
end
