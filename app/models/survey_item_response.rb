# frozen_string_literal: true

class SurveyItemResponse < ActiveRecord::Base
  TEACHER_RESPONSE_THRESHOLD = 2
  STUDENT_RESPONSE_THRESHOLD = 2

  belongs_to :academic_year
  belongs_to :school
  belongs_to :survey_item, counter_cache: true
  has_one :measure, through: :survey_item

  scope :exclude_boston, lambda {
                           boston = District.find_by_name('Boston')
                           where.not(school: boston.schools) if boston.present?
                         }
end
