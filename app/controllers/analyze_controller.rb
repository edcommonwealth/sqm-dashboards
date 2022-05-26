class AnalyzeController < SqmApplicationController
  def index
    @category ||= Category.find_by_category_id(params[:category_id])
    @category ||= Category.find_by_category_id(1)

    @subcategory ||= Subcategory.find_by_subcategory_id(params[:subcategory_id])
    @subcategory ||= Subcategory.order(:subcategory_id).includes(%i[measures]).first

    @measures = @subcategory.measures.order(:measure_id).includes(%i[scales admin_data_items])

    @academic_year ||= AcademicYear.order('range DESC').first
  end
end
