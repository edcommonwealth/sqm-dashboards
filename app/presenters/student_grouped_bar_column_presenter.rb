class StudentGroupedBarColumnPresenter < GroupedBarColumnPresenter
  def label
    'All Students'
  end

  def basis
    'student'
  end

  def show_irrelevancy_message?
    !@measure.includes_student_survey_items?
  end

  def show_insufficient_data_message?
    !score.meets_student_threshold?
  end

  # def score
  #   @measure.student_score(school: @school, academic_year: @academic_year)
  # end
end
