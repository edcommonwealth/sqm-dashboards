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

  def variance_chart_row_presenters
    scales.map(&method(:presenter_for_scale))
  end

  def scales
    measures.flat_map { |measure| measure.scales.parent_scales }
  end

  private

  def presenter_for_scale(scale)
    score = scale.parent_score(school: @school, academic_year: @academic_year)
    score = Score.new(average: score, meets_teacher_threshold: true, meets_student_threshold: true)

    Overview::VarianceChartRowPresenter.new(construct: scale, score:)
  end
end
