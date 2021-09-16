class Array
  def average
    self.sum.to_f / self.size
  end
end

class SurveyResponseAggregator
  def self.score(academic_year:, school:, construct:)
    SurveyResponse
      .where(academic_year: academic_year)
      .where(school: school)
      .filter { |survey_response| survey_response.survey_item.construct == construct }
      .map { |survey_response| survey_response.likert_score }
      .average
  end
end
