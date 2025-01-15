# frozen_string_literal: true

class Respondent < ApplicationRecord
  belongs_to :school
  belongs_to :academic_year

  validates :school, uniqueness: { scope: :academic_year }
  GRADE_SYMBOLS = { -1 => :pk, 0 => :k, 1 => :one, 2 => :two, 3 => :three, 4 => :four, 5 => :five, 6 => :six,
                    7 => :seven, 8 => :eight, 9 => :nine, 10 => :ten, 11 => :eleven, 12 => :twelve }

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

  def for_grade(grade)
    send(GRADE_SYMBOLS[grade])
  end

  def total_educators
    (total_teachers || 0) + (total_esp || 0)
  end
end
