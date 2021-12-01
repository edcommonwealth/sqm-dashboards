class School < ApplicationRecord
  belongs_to :district

  has_many :survey_item_responses, dependent: :delete_all

  validates :name, presence: true

  scope :alphabetic, -> { order(name: :asc) }

  include FriendlyId
  friendly_id :name, use: [:slugged]

  def self.find_by_district_code_and_school_code(district_code, school_code)
    School
      .joins(:district)
      .where(districts: { qualtrics_code: district_code })
      .find_by_qualtrics_code(school_code)
  end
end
