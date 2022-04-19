class Scale < ApplicationRecord
  belongs_to :measure
  has_many :survey_items
  has_many :survey_item_responses, through: :survey_items
  has_many :admin_data_items

  def score(school:, academic_year:)
    @score ||= Hash.new do |memo|
      memo[[school, academic_year]] = begin
        items = []
        items << collect_survey_item_average(student_survey_items(school:, academic_year:), school, academic_year)
        items << collect_survey_item_average(teacher_survey_items, school, academic_year)

        items.remove_zeros.average
      end
    end
    @score[[school, academic_year]]
  end

  scope :teacher_scales, lambda {
    where("scale_id LIKE 't-%'")
  }
  scope :student_scales, lambda {
    where("scale_id LIKE 's-%'")
  }

  private

  def collect_survey_item_average(survey_items, school, academic_year)
    survey_items.map do |survey_item|
      survey_item.score(school:, academic_year:)
    end.remove_zeros.average
  end

  def teacher_survey_items
    survey_items.teacher_survey_items
  end

  def student_survey_items(school:, academic_year:)
    survey = Survey.where(school:, academic_year:).first
    return survey_items.student_survey_items.short_form_items if survey.form == 'short'

    survey_items.student_survey_items
  end
end
