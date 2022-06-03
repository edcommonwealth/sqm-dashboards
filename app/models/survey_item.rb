class SurveyItem < ActiveRecord::Base
  belongs_to :scale
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
    where("survey_item_id LIKE 's-%'")
  }
  scope :teacher_survey_items, lambda {
    where("survey_item_id LIKE 't-%'")
  }
  scope :short_form_items, lambda {
    where(on_short_form: true)
  }
end
