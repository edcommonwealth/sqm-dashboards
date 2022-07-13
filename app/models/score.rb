# frozen_string_literal: true

class Score < Struct.new(:average, :meets_teacher_threshold?, :meets_student_threshold?, :meets_admin_data_threshold?)
  NIL_SCORE = Score.new(nil, false, false, false)
  def in_zone?(zone:)
    return false if average.nil? || average.is_a?(Float) && average.nan?

    average.between?(zone.low_benchmark, zone.high_benchmark)
  end

  def blank?
    average.nil? || average.zero? || average.nan?
  end
end
