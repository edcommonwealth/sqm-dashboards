class AnalyzeController < SqmApplicationController
  def index
    @category ||= Category.find_by_category_id(params[:category])
    @categories = Category.all.order(:category_id)

    @subcategory ||= @category.subcategories.order(:subcategory_id).first
    @subcategory ||= Subcategory.order(:subcategory_id).includes(%i[measures]).first

    @measures = @subcategory.measures.order(:measure_id).includes(%i[scales admin_data_items])
  end
end
