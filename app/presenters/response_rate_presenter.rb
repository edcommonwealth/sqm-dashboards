class ResponseRatePresenter
  attr_reader :focus, :academic_year, :school, :survey_items

  def initialize(focus:, academic_year:, school:)
    @focus = focus
    @academic_year = academic_year
    @school = school
    if focus == :student
      @survey_items = Measure.all.flat_map do |measure|
        measure.student_survey_items_with_sufficient_responses(school:, academic_year:)
      end
    end
    @survey_items = SurveyItem.teacher_survey_items if focus == :teacher
  end

  def date
    SurveyItemResponse.where(survey_item: survey_items, school:,
                             academic_year:).order(recorded_date: :DESC).first&.recorded_date || Date.today
  end

  def percentage
    return 0 if respondents_count.zero?

    cap_at_100(actual_count.to_f / respondents_count.to_f * 100).round
  end

  def color
    percentage > 75 ? "purple" : "gold"
  end

  def hover_message
    "Percentages based on #{actual_count} out of #{respondents_count.round} #{focus}s completing at least 25% of the survey."
  end

  private

  def cap_at_100(value)
    value > 100 ? 100 : value
  end

  def actual_count
    if focus == :teacher
      response_count_for_survey_items(survey_items:)
    else
      non_early_ed_items = survey_items - SurveyItem.early_education_survey_items
      non_early_ed_count = response_count_for_survey_items(survey_items: non_early_ed_items)

      early_ed_items = survey_items & SurveyItem.early_education_survey_items
      early_ed_count = SurveyItemResponse.where(school:, academic_year:,
                                                survey_item: early_ed_items)
                                         .group(:survey_item)
                                         .select(:response_id)
                                         .distinct
                                         .count
                                         .reduce(0) do |largest, row|
        count = row[1]
        if count > largest
          count
        else
          largest
        end
      end

      non_early_ed_count + early_ed_count
    end
  end

  def response_count_for_survey_items(survey_items:)
    SurveyItemResponse.where(school:, academic_year:,
                             survey_item: survey_items).select(:response_id).distinct.count || 0
  end

  def respondents_count
    return 0 if respondents.nil?

    count = enrollment if focus == :student
    count = respondents.total_teachers if focus == :teacher
    count
  end

  def enrollment
    SurveyItemResponse.where(school:, academic_year:, grade: grades,
                             survey_item: SurveyItem.student_survey_items)
                      .select(:grade)
                      .distinct
                      .pluck(:grade)
                      .reject(&:nil?)
                      .map do |grade|
      respondents.counts_by_grade[grade]
    end.sum.to_f
  end

  def respondents
    Respondent.find_by(school:, academic_year:)
  end

  def grades
    respondents.counts_by_grade.keys
  end
end
