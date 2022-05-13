class AnalyzeController < SqmApplicationController
  def index
    @category ||= Category.find_by_category_id(params[:category_id])
    @category ||= Category.find_by_category_id(1)

    @subcategory ||= Subcategory.find_by_subcategory_id(params[:subcategory_id])
    @subcategory ||= Subcategory.find_by_subcategory_id('1A')
  end
end
