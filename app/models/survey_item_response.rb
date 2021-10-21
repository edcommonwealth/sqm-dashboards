class SurveyItemResponse < ActiveRecord::Base
  TEACHER_RESPONSE_THRESHOLD = 17
  STUDENT_RESPONSE_THRESHOLD = 196

  belongs_to :academic_year
  belongs_to :school
  belongs_to :survey_item

  scope :for_measures, ->(measures) { joins(:survey_item).where('survey_items.measure_id': measures.map(&:id)) }
  scope :for_measure, ->(measure) { joins(:survey_item).where('survey_items.measure_id': measure.id) }

  def self.sufficient_data?(measure:, academic_year:, school:)
    meets_teacher_threshold = true
    meets_student_threshold = true

    if measure.includes_teacher_survey_items?
      meets_teacher_threshold = SurveyItemResponse.for_measure(measure).where("survey_items.survey_item_id LIKE 't-%'").where(academic_year: academic_year, school: school).count >= TEACHER_RESPONSE_THRESHOLD
    end

    if measure.includes_student_survey_items?
      meets_student_threshold = SurveyItemResponse.for_measure(measure).where("survey_items.survey_item_id LIKE 's-%'").where(academic_year: academic_year, school: school).count >= STUDENT_RESPONSE_THRESHOLD
    end

    meets_teacher_threshold and meets_student_threshold
  end
end
