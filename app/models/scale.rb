class Scale < ApplicationRecord
  belongs_to :measure
  has_many :survey_items
  has_many :admin_data_items

  def score(school:, academic_year:)
    @score ||= Hash.new do |memo|
      memo[[school, academic_year]] = begin
        items = []
        items << student_survey_items(school:, academic_year:)
        items << teacher_survey_items

        items.flatten.map do |survey_item|
          survey_item.score(school:, academic_year:)
        end.average
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

  def teacher_survey_items
    survey_items.teacher_survey_items
  end

  def student_survey_items(school:, academic_year:)
    survey = Survey.where(school:, academic_year:).first
    return survey_items.student_survey_items.short_form_items if survey.form == 'short'

    survey_items.student_survey_items
  end
end
