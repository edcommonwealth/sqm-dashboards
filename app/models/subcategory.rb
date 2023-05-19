# frozen_string_literal: true

class Subcategory < ActiveRecord::Base
  belongs_to :category, counter_cache: true

  has_many :measures
  has_many :survey_items, through: :measures

  def score(school:, academic_year:)
    measures.map do |measure|
      measure.score(school:, academic_year:).average
    end.remove_blanks.average
  end

  def student_score(school:, academic_year:)
    measures.map do |measure|
      measure.student_score(school:, academic_year:).average
    end.remove_blanks.average
  end

  def teacher_score(school:, academic_year:)
    measures.map do |measure|
      measure.teacher_score(school:, academic_year:).average
    end.remove_blanks.average
  end

  def admin_score(school:, academic_year:)
    measures.map do |measure|
      measure.admin_score(school:, academic_year:).average
    end.remove_blanks.average
  end

  def student_score(school:, academic_year:)
    measures.map do |measure|
      measure.student_score(school:, academic_year:).average
    end.compact.average
  end

  def teacher_score(school:, academic_year:)
    measures.map do |measure|
      measure.teacher_score(school:, academic_year:).average
    end.compact.average
  end

  def admin_score(school:, academic_year:)
    measures.map do |measure|
      measure.admin_score(school:, academic_year:).average
    end.compact.average
  end

  def response_rate(school:, academic_year:)
    @response_rate ||= Hash.new do |memo, (school, academic_year)|
      student = StudentResponseRateCalculator.new(subcategory: self, school:, academic_year:)
      teacher = TeacherResponseRateCalculator.new(subcategory: self, school:, academic_year:)
      memo[[school, academic_year]] = ResponseRate.new(school:, academic_year:, subcategory: self, student_response_rate: student.rate,
                                                       teacher_response_rate: teacher.rate, meets_student_threshold: student.meets_student_threshold?,
                                                       meets_teacher_threshold: teacher.meets_teacher_threshold?)
    end

    @response_rate[[school, academic_year]]
  end

  def warning_low_benchmark
    1
  end

  def watch_low_benchmark
    @watch_low_benchmark ||= benchmark(:watch_low_benchmark)
  end

  def growth_low_benchmark
    @growth_low_benchmark ||= benchmark(:growth_low_benchmark)
  end

  def approval_low_benchmark
    @approval_low_benchmark ||= benchmark(:approval_low_benchmark)
  end

  def ideal_low_benchmark
    @ideal_low_benchmark ||= benchmark(:ideal_low_benchmark)
  end

  def benchmark(name)
    measures.map do |measure|
      measure.benchmark(name)
    end.average
  end

  def zone(school:, academic_year:)
    zone_for_score(score: score(school:, academic_year:))
  end

  def student_zone(school:, academic_year:)
    zone_for_score(score: student_score(school:, academic_year:))
  end

  def teacher_zone(school:, academic_year:)
    zone_for_score(score: teacher_score(school:, academic_year:))
  end

  def admin_zone(school:, academic_year:)
    zone_for_score(score: admin_score(school:, academic_year:))
  end

  def zone_for_score(score:)
    Zones.new(watch_low_benchmark:, growth_low_benchmark:,
              approval_low_benchmark:, ideal_low_benchmark:).zone_for_score(score)
  end
end
