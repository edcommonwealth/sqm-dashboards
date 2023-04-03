# frozen_string_literal: true

class SurveyItemResponse < ActiveRecord::Base
  TEACHER_RESPONSE_THRESHOLD = 2
  STUDENT_RESPONSE_THRESHOLD = 10

  belongs_to :academic_year
  belongs_to :school
  belongs_to :survey_item, counter_cache: true
  belongs_to :student, foreign_key: :student_id, optional: true
  belongs_to :gender

  has_one :measure, through: :survey_item

  scope :exclude_boston, lambda {
                           boston = District.find_by_name('Boston')
                           where.not(school: boston.schools) if boston.present?
                         }

  scope :averages_for_grade, ->(survey_items, school, academic_year, grade) {
            SurveyItemResponse.where(survey_item: survey_items, school:,
                                                academic_year: , grade:).group(:survey_item).average(:likert_score)
  }

  scope :averages_for_gender, ->(survey_items, school, academic_year, gender) {
            SurveyItemResponse.where(survey_item: survey_items, school:,
                                                academic_year: , gender:).group(:survey_item).average(:likert_score)
  }
end
