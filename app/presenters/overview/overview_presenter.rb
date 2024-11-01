class Overview::OverviewPresenter
  attr_reader :view, :school, :academic_year

  def initialize(params:, school:, academic_year:)
    @view = params[:view] || "student"
    @school = school
    @academic_year = academic_year
  end

  def variance_chart_row_presenters
    measures.map(&method(:presenter_for_measure))
  end

  def category_presenters
    categories.map { |category| CategoryPresenter.new(category:) }
  end

  def measures
    @measures ||= subcategories.flat_map(&:measures)
  end

  def subcategories
    @subcategories ||= categories.flat_map(&:subcategories)
  end

  def framework_indicator_class
    "school-quality-frameworks"
  end

  def show_student_response_rates
    view == "student"
  end

  def categories
    Category.sorted.includes(%i[measures scales admin_data_items subcategories])
  end

  def student_response_rate_presenter
    ResponseRatePresenter.new(focus: :student, school: @school, academic_year: @academic_year)
  end

  def teacher_response_rate_presenter
    ResponseRatePresenter.new(focus: :teacher, school: @school, academic_year: @academic_year)
  end

  def parent_response_rate_presenter
    ResponseRatePresenter.new(focus: :parent, school: @school, academic_year: @academic_year)
  end

  def presenter_for_measure(measure)
    score = measure.score(school: @school, academic_year: @academic_year)

    Overview::VarianceChartRowPresenter.new(construct: measure, score:)
  end

  def empty_dataset?
    subcategories.none? do |subcategory|
      response_rate = subcategory.response_rate(school: @school, academic_year: @academic_year)
      response_rate.meets_student_threshold || response_rate.meets_teacher_threshold
    end
  end
end
