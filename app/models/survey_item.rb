# frozen_string_literal: true

class SurveyItem < ActiveRecord::Base
  belongs_to :scale, counter_cache: true
  has_one :measure, through: :scale
  has_one :subcategory, through: :measure

  has_many :survey_item_responses

  def score(school:, academic_year:)
    @score ||= Hash.new do |memo, (school, academic_year)|
      memo[[school, academic_year]] =
        survey_item_responses.exclude_boston.where(school:, academic_year:).average(:likert_score).to_f
    end
    @score[[school, academic_year]]
  end

  scope :student_survey_items, lambda {
    where("survey_items.survey_item_id LIKE 's-%'")
  }
  scope :standard_survey_items, lambda {
    where("survey_items.survey_item_id LIKE 's-%-q%'")
  }
  scope :teacher_survey_items, lambda {
    where("survey_items.survey_item_id LIKE 't-%'")
  }
  scope :short_form_survey_items, lambda {
    where(on_short_form: true)
  }
  scope :early_education_survey_items, lambda {
    where("survey_items.survey_item_id LIKE '%-%-es%'")
  }

  scope :survey_items_for_grade, lambda { |school, academic_year, grade|
    includes(:survey_item_responses)
      .where("survey_item_responses.grade": grade,
             "survey_item_responses.school": school,
             "survey_item_responses.academic_year": academic_year).distinct
  }

  scope :survey_item_ids_for_grade, lambda { |school, academic_year, grade|
    survey_items_for_grade(school, academic_year, grade).pluck(:survey_item_id)
  }

  scope :survey_items_for_grade_and_subcategory, lambda { |school, academic_year, grade, subcategory|
    includes(:survey_item_responses)
      .where(
        survey_item_id: subcategory.survey_items.pluck(:survey_item_id),
        "survey_item_responses.school": school,
        "survey_item_responses.academic_year": academic_year,
        "survey_item_responses.grade": grade
      )
  }

  scope :survey_type_for_grade, lambda { |school, academic_year, grade|
    survey_items_set_by_grade = survey_items_for_grade(school, academic_year, grade).pluck(:survey_item_id).to_set
    if survey_items_set_by_grade.size > 0 && survey_items_set_by_grade.subset?(early_education_survey_items.pluck(:survey_item_id).to_set)
      return :early_education
    end

    :standard
  }

  # TODO: rename this to Summary
  def description
    Summary.new(survey_item_id, prompt, true)
  end

  def self.counts_by_survey_item(school:, academic_year:, survey_items:)
    @counts_by_survey_item ||= Hash.new do |memo, (school, academic_year, survey_items)|
      respondents = Respondent.find_by(school:, academic_year:)
      next {} if respondents.nil?

      grades = respondents.counts_by_grade.keys
      threshold = 10
      memo[[school, academic_year, survey_items]] =
        SurveyItemResponse.where(school:, academic_year:, survey_item: survey_items, grade: grades)
                          .group(:survey_item_id)
                          .having("count(*) >= #{threshold}")
                          .count
    end
    @counts_by_survey_item[[school, academic_year, survey_items]]
  end

  def self.average_count(school:, academic_year:, survey_items:)
    @average_count ||= Hash.new do |memo, (school, academic_year, survey_items)|
      memo[[school, academic_year, survey_items]] =
        counts_by_survey_item(school:, academic_year:, survey_items:).values.average
    end
    @average_count[[school, academic_year, survey_items]]
  end

  def self.difference_from_mean(school:, academic_year:, survey_items:, survey_item_id:)
    count = counts_by_survey_item(school:, academic_year:, survey_items:)[survey_item_id]
    average = average_count(school:, academic_year:, survey_items:)
    return nil if average.nil? || average.zero? || count.nil? || count.zero?

    ((count - average) / average) * 100
  end

  def self.survey_type(survey_item_ids:)
    survey_item_ids = survey_item_ids.to_set
    return :short_form if survey_item_ids.subset? short_form_survey_items.map(&:survey_item_id).to_set
    return :early_education if survey_item_ids.subset? early_education_survey_items.map(&:survey_item_id).to_set
    return :teacher if survey_item_ids.subset? teacher_survey_items.map(&:survey_item_id).to_set
    return :standard if survey_item_ids.subset? standard_survey_items.map(&:survey_item_id).to_set

    :unknown
  end
end
