class TeacherGroupedBarColumnPresenter < GroupedBarColumnPresenter
  def label
    'All Teachers'
  end

  def basis
    'teacher'
  end

  def show_irrelevancy_message?
    !@measure.includes_teacher_survey_items?
  end

  def show_insufficient_data_message?
    !score.meets_teacher_threshold?
  end

  # def score
  #   @measure.teacher_score(school: @school, academic_year: @academic_year)
  # end
end
