class Overview::ParentOverviewPresenter < Overview::OverviewPresenter
  def categories
    Category.sorted.includes(%i[measures scales admin_data_items subcategories]).select do |category|
      category.survey_items.parent_survey_items.count.positive?
    end
  end

  def category_presenters
    categories.map { |category| ParentCategoryPresenter.new(category:) }
  end

  def framework_indicator_class
    "school-quality-frameworks-parent"
  end
end
