class Scale < ApplicationRecord
  belongs_to :measure
  has_many :survey_items
  has_many :admin_data_items

  def score(school:, academic_year:)
    @score ||= Hash.new do |memo|
      memo[[school, academic_year]] = survey_items.map do |survey_item|
        survey_item.score(school:, academic_year:)
      end.average
    end
    @score[[school, academic_year]]
  end

  scope :teacher_scales, lambda {
    where("scale_id LIKE 't-%'")
  }
  scope :student_scales, lambda {
    where("scale_id LIKE 's-%'")
  }
end
