class StudentResponseRatePresenter < ResponseRatePresenter
  def initialize(academic_year:, school:)
    super(academic_year:, school:)
    @survey_items = Measure.all.flat_map do |measure|
      measure.student_survey_items_with_sufficient_responses(school:, academic_year:)
    end
  end

  def actual_count
    # Early ed surveys are given in batches so they have to be counted separately because we have to account for the same student having a different response id per batch
    non_early_ed_items = survey_items - SurveyItem.early_education_survey_items
    non_early_ed_count = response_count_for_survey_items(survey_items: non_early_ed_items)

    early_ed_items = SurveyItem.early_education_survey_items
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

  def respondents_count
    return 0 if respondents.nil?

    enrollment
  end

  def focus
    "student"
  end
end

