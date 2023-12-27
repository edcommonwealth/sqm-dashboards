# frozen_string_literal: true

class Respondent < ApplicationRecord
  belongs_to :school
  belongs_to :academic_year

  validates :school, uniqueness: { scope: :academic_year }

  def enrollment_by_grade
    @enrollment_by_grade ||= {}.tap do |row|
      attributes = %i[pk k one two three four five six seven eight nine ten eleven twelve]
      grades = [-1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
      attributes.zip(grades).each do |attribute, grade|
        count = send(attribute) if send(attribute).present?
        row[grade] = count unless count.nil? || count.zero?
      end
    end
  end

  def self.by_school_and_year(school:, academic_year:)
    @by_school_and_year ||= Hash.new do |memo, (school, academic_year)|
      memo[[school, academic_year]] = Respondent.find_by(school:, academic_year:)
    end

    @by_school_and_year[[school, academic_year]]
  end
end
