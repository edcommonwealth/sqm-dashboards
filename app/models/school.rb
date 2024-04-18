# frozen_string_literal: true

class School < ApplicationRecord
  belongs_to :district

  has_many :survey_item_responses, dependent: :delete_all

  validates :name, presence: true

  scope :alphabetic, -> { order(name: :asc) }
  scope :by_dese_id, -> { all.map { |school| [school.dese_id, school] }.to_h }

  include FriendlyId
  friendly_id :name, use: [:slugged]

  def self.find_by_district_code_and_school_code(district_code, school_code)
    School
      .joins(:district)
      .where(districts: { qualtrics_code: district_code })
      .find_by_qualtrics_code(school_code)
  end

  def grades(academic_year:)
    @grades ||= Respondent.by_school_and_year(school: self, academic_year:)&.enrollment_by_grade&.keys || (-1..12).to_a
  end
end
