# frozen_string_literal: true

class SurveyItemResponse < ActiveRecord::Base
  TEACHER_RESPONSE_THRESHOLD = 2
  STUDENT_RESPONSE_THRESHOLD = 10

  belongs_to :academic_year
  belongs_to :school
  belongs_to :survey_item, counter_cache: true
  belongs_to :student, foreign_key: :student_id, optional: true
  belongs_to :gender
  belongs_to :income
  belongs_to :ell
  belongs_to :sped

  has_one :measure, through: :survey_item

  scope :exclude_boston, lambda {
                           boston = District.find_by_name("Boston")
                           where.not(school: boston.schools) if boston.present?
                         }

  scope :averages_for_grade, lambda { |survey_items, school, academic_year, grade|
    SurveyItemResponse.where(survey_item: survey_items, school:,
                             academic_year:, grade:).group(:survey_item).having("count(*) >= 10").average(:likert_score)
  }

  scope :averages_for_gender, lambda { |survey_items, school, academic_year, gender|
    SurveyItemResponse.where(survey_item: survey_items, school:,
                             academic_year:, gender:, grade: school.grades(academic_year:)).group(:survey_item).having("count(*) >= 10").average(:likert_score)
  }

  scope :averages_for_income, lambda { |survey_items, school, academic_year, income|
    SurveyItemResponse.where(survey_item: survey_items, school:,
                             academic_year:, income:, grade: school.grades(academic_year:)).group(:survey_item).having("count(*) >= 10").average(:likert_score)
  }

  scope :averages_for_ell, lambda { |survey_items, school, academic_year, ell|
    SurveyItemResponse.where(survey_item: survey_items, school:,
                             academic_year:, ell:, grade: school.grades(academic_year:)).group(:survey_item).having("count(*) >= 10").average(:likert_score)
  }

  scope :averages_for_sped, lambda { |survey_items, school, academic_year, sped|
    SurveyItemResponse.where(survey_item: survey_items, school:,
                             academic_year:, sped:, grade: school.grades(academic_year:)).group(:survey_item).having("count(*) >= 10").average(:likert_score)
  }

  scope :averages_for_race, lambda { |school, academic_year, race|
    SurveyItemResponse.joins("JOIN student_races on survey_item_responses.student_id = student_races.student_id JOIN students on students.id = student_races.student_id").where(
      school:, academic_year:, grade: school.grades(academic_year:)
    ).where("student_races.race_id": race.id).group(:survey_item_id).having("count(*) >= 10").average(:likert_score)
  }
end
