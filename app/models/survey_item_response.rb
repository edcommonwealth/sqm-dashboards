# frozen_string_literal: true

class SurveyItemResponse < ActiveRecord::Base
  TEACHER_RESPONSE_THRESHOLD = 2
  STUDENT_RESPONSE_THRESHOLD = 2

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

  scope :averages_for_grade, lambda { |survey_items, school, academic_year, grade|
    SurveyItemResponse.where(survey_item: survey_items, school:,
                             academic_year:, grade:).group(:survey_item).average(:likert_score)
  }

  scope :averages_for_gender, lambda { |survey_items, school, academic_year, gender|
    SurveyItemResponse.where(survey_item: survey_items, school:,
                             academic_year:, gender:).group(:survey_item).average(:likert_score)
  }

  # grouped_responses = SurveyItemResponse.where(academic_year:, school:, survey_item: student_survey_items).group(["survey_item_id, grade"]).count
  #  grouped_responses = SurveyItemResponse.select("survey_item_id, grade, count(survey_item_id) as count").group("survey_item_id, grade")
  #  grade_zeroitems = SurveyItemResponse.where(grade: 0, school:, academic_year:).select(:survey_item_id).distinct.to_set
  #  grade_zeroitems.subset? all_student_survey_items
  #  SurveyItem.includes(:survey_item_responses).where("survey_item_responses.grade": 0,"survey_item_responses.school": school , "survey_item_responses.academic_year": academic_year).distinct(:survey_item_id).count
end
