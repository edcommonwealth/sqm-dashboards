class SurveyItem < ActiveRecord::Base
  belongs_to :measure
  has_many :survey_item_responses

  scope :student_survey_items_for_measures, lambda { |measures|
    joins(:measure).where(measure: measures).where("survey_item_id LIKE 's-%'")
  }
  scope :teacher_survey_items_for_measures, lambda { |measures|
    joins(:measure).where(measure: measures).where("survey_item_id LIKE 't-%'")
  }
end
