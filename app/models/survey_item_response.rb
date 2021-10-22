class SurveyItemResponse < ActiveRecord::Base
  TEACHER_RESPONSE_THRESHOLD = 17
  STUDENT_RESPONSE_THRESHOLD = 196

  belongs_to :academic_year
  belongs_to :school
  belongs_to :survey_item

  scope :for_measure, ->(measure) { joins(:survey_item).where('survey_items.measure_id': measure.id) }

  def self.score_for_subcategory(subcategory:, school:, academic_year:)
    SurveyItemResponse.for_measures(subcategory.measures)
                      .where(academic_year: academic_year, school: school)
                      .average(:likert_score)
  end

  def self.score_for_measure(measure:, school:, academic_year:)
    return nil unless SurveyItemResponse.sufficient_data?(measure: measure, school: school, academic_year: academic_year)

    SurveyItemResponse.for_measure(measure)
                      .where(academic_year: academic_year, school: school)
                      .average(:likert_score)
  end

  private

  scope :for_measures, ->(measures) { joins(:survey_item).where('survey_items.measure_id': measures.map(&:id)) }
  scope :teacher_responses_for_measure, ->(measure) { for_measure(measure).where("survey_items.survey_item_id LIKE 't-%'") }
  scope :student_responses_for_measure, ->(measure) { for_measure(measure).where("survey_items.survey_item_id LIKE 's-%'") }

  def self.sufficient_data?(measure:, school:, academic_year:)
    meets_teacher_threshold = true
    meets_student_threshold = true

    if measure.includes_teacher_survey_items?
      teacher_survey_item_responses = SurveyItemResponse.teacher_responses_for_measure(measure).where(academic_year: academic_year, school: school)
      average_number_of_survey_item_responses = teacher_survey_item_responses.count / measure.teacher_survey_items.count

      meets_teacher_threshold = average_number_of_survey_item_responses >= TEACHER_RESPONSE_THRESHOLD
    end

    if measure.includes_student_survey_items?
      student_survey_item_responses = SurveyItemResponse.student_responses_for_measure(measure).where(academic_year: academic_year, school: school)
      average_number_of_survey_item_responses = student_survey_item_responses.count / measure.student_survey_items.count

      meets_student_threshold = average_number_of_survey_item_responses >= STUDENT_RESPONSE_THRESHOLD
    end

    meets_teacher_threshold and meets_student_threshold
  end
end
