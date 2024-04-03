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

  def self.survey_type(survey_item_ids:)
    # Ignore any survey item variants. Sometimes multiple versions of questions are ask targeting specific age brackets.  The questions relate to the same idea so we only show one variant of the question on the dashboard
    survey_item_ids = survey_item_ids.reject { |id| id.ends_with?("-1") }.to_set
    # Ignore any library items. School leadership asked for these questions on the survey. They do not need to be shown on the dashboard.
    survey_item_ids = survey_item_ids.reject { |id| id.include?("libr") || id.include?("libp") }.to_set
    return :short_form if survey_item_ids.subset? short_form_survey_items.map(&:survey_item_id).to_set
    return :early_education if survey_item_ids.subset? early_education_survey_items.map(&:survey_item_id).to_set
    return :teacher if survey_item_ids.subset? teacher_survey_items.map(&:survey_item_id).to_set
    return :standard if survey_item_ids.subset? standard_survey_items.map(&:survey_item_id).to_set

    :unknown
  end
end
