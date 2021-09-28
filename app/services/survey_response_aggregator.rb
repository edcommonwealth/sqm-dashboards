# TODO inline me pls
class SurveyResponseAggregator
  # Returns an average score for all SurveyItemResponses for the given AcademicYear, School, and Measure
  def self.score(academic_year:, school:, measure:)
    SurveyItemResponse.for_measure(measure)
      .where(academic_year: academic_year, school: school)
      .average(:likert_score)
  end

  # Returns an array of SurveyItemResponses for the given AcademicYear, School, and Measure 
  def self.find_responses_by_measure(academic_year:, school:, measure:)
    SurveyItemResponse
      .where(academic_year: academic_year, school: school)
      .joins(:survey_item).where('survey_items.measure_id': measure.id)
  end
end
