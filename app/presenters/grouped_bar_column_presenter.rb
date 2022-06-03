class GroupedBarColumnPresenter
  include AnalyzeHelper
  include ColorHelper

  attr_reader :measure_name, :measure_id, :category, :position, :measure, :school, :academic_years

  def initialize(measure:, school:, academic_years:, position:)
    @measure = measure
    @measure_name = @measure.name
    @measure_id = @measure.measure_id
    @category = @measure.subcategory.category
    @school = school
    @academic_years = academic_years
    @position = position
  end

  def score(year_index)
    measure.score(school:, academic_year: academic_years[year_index])
  end

  def bars
    @bars ||= yearly_scores.map.each_with_index do |item, index|
      year = item[0]
      score = item[1]
      AnalyzeBarPresenter.new(measure:, academic_year: year, score:, x_position: bar_x(index),
                              color: bar_color(year))
    end
  end

  def label
    'All Survey Data'
  end

  def basis
    ''
  end

  def show_irrelevancy_message?
    !measure.includes_teacher_survey_items? && !measure.includes_student_survey_items?
  end

  def show_insufficient_data_message?
    scores = academic_years.map do |year|
      measure.score(school:, academic_year: year)
    end

    scores.all? { |score| !score.meets_teacher_threshold? && !score.meets_student_threshold? }
  end

  def column_midpoint
    zone_label_width + (grouped_chart_column_width * (position + 1)) - (grouped_chart_column_width / 2)
  end

  def bar_width
    3.5
  end

  def message_x
    column_midpoint - message_width / 2
  end

  def message_y
    17
  end

  def message_width
    20
  end

  def message_height
    34
  end

  def column_end_x
    zone_label_width + (grouped_chart_column_width * (position + 1))
  end

  def column_start_x
    zone_label_width + (grouped_chart_column_width * position)
  end

  private

  def yearly_scores
    yearly_scores = academic_years.each_with_index.map do |year, index|
      [year, score(index)]
    end
    yearly_scores.reject do |yearly_score|
      score = yearly_score[1]
      score.average.nil? || score.average.zero? || score.average.nan?
    end
  end

  def bar_color(year)
    @available_academic_years ||= AcademicYear.order(:range).all
    colors[@available_academic_years.find_index(year)]
  end

  def bar_x(index)
    column_start_x + (index * bar_width * 1.2) + ((column_end_x - column_start_x) - (yearly_scores.size * bar_width * 1.2)) / 2
  end
end
