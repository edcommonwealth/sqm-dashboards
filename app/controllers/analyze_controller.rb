class AnalyzeController < SqmApplicationController
  def index
    @category ||= Category.find_by_category_id(params[:category])
    @categories = Category.all.order(:category_id)

    @subcategories = @category.subcategories.order(:subcategory_id)
    @subcategory ||= Subcategory.find_by_subcategory_id(params[:subcategory])
    @subcategory ||= @subcategories.first

    @measures = @subcategory.measures.order(:measure_id).includes(%i[scales admin_data_items])
  end
end
