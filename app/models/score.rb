# frozen_string_literal: true

class Score < ApplicationRecord
  belongs_to :measure
  belongs_to :school
  belongs_to :academic_year
  belongs_to :race

  NIL_SCORE = Score.new(average: nil, meets_teacher_threshold: false, meets_student_threshold: false,
                        meets_admin_data_threshold: false)

  def in_zone?(zone:)
    return false if average.nil? || average.is_a?(Float) && average.nan?

    average.between?(zone.low_benchmark, zone.high_benchmark)
  end

  def blank?
    average.nil? || average.zero? || average.nan?
  end
end
