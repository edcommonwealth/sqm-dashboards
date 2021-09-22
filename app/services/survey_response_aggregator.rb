class Array
  def average
    self.sum.to_f / self.size
  end
end

class SurveyResponseAggregator
  def self.score(academic_year:, school:, measure:)
    SurveyItemResponse
      .where(academic_year: academic_year, school: school)
      .joins(:survey_item).where('survey_items.measure_id': measure.id)
      .map { |survey_item_response| survey_item_response.likert_score }
      .average
  end
end
