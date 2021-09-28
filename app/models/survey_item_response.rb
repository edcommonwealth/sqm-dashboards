class SurveyItemResponse < ActiveRecord::Base
  belongs_to :academic_year
  belongs_to :school
  belongs_to :survey_item

  scope :for_measures, ->(measures) { joins(:survey_item).where('survey_items.measure_id': measures.map(&:id)) }
  scope :for_measure, ->(measure) { joins(:survey_item).where('survey_items.measure_id': measure.id) }
end
