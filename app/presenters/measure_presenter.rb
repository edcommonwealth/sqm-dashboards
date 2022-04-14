class MeasurePresenter
  def initialize(measure:, academic_year:, school:)
    @measure = measure
    @academic_year = academic_year
    @school = school
  end

  def id
    @measure.measure_id
  end

  def name
    @measure.name
  end

  def description
    @measure.description
  end

  def gauge_presenter
    GaugePresenter.new(zones:, score: score_for_measure.average)
  end

  def data_item_accordion_id
    "data-item-accordion-#{@measure.measure_id}"
  end

  def data_item_presenters
    [].tap do |array|
      if @measure.student_survey_items.any?
        array << StudentSurveyPresenter.new(measure_id: @measure.measure_id, survey_items: @measure.student_survey_items,
                                            has_sufficient_data: score_for_measure.meets_student_threshold?)
      end
      if @measure.teacher_survey_items.any?
        array << TeacherSurveyPresenter.new(measure_id: @measure.measure_id, survey_items: @measure.teacher_survey_items,
                                            has_sufficient_data: score_for_measure.meets_teacher_threshold?)
      end
      if @measure.admin_data_items.any?
        array << AdminDataPresenter.new(measure_id: @measure.measure_id,
                                        admin_data_items: @measure.admin_data_items, has_sufficient_data: score_for_measure.meets_admin_data_threshold?)
      end
    end
  end

  private

  def score_for_measure
    @score ||= @measure.score(school: @school, academic_year: @academic_year)
  end

  def zones
    Zones.new(
      watch_low_benchmark: @measure.watch_low_benchmark,
      growth_low_benchmark: @measure.growth_low_benchmark,
      approval_low_benchmark: @measure.approval_low_benchmark,
      ideal_low_benchmark: @measure.ideal_low_benchmark
    )
  end
end
