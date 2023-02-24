# frozen_string_literal: true

class Subcategory < ActiveRecord::Base
  belongs_to :category, counter_cache: true

  has_many :measures
  has_many :survey_items, through: :measures

  def score(school:, academic_year:)
    scores = measures.map do |measure|
      measure.score(school:, academic_year:).average
    end
    scores = scores.reject(&:nil?)
    scores.average
  end

  def response_rate(school:, academic_year:)
    @response_rate ||= Hash.new do |memo, (school, academic_year)|
      memo[[school, academic_year]] = ResponseRate.find_by(subcategory: self, school:, academic_year:)
    end

    @response_rate[[school, academic_year]] || create_response_rate(school:, academic_year:)
  end

  private

  def create_response_rate(school:, academic_year:)
    student = StudentResponseRateCalculator.new(subcategory: self, school:, academic_year:)
    teacher = TeacherResponseRateCalculator.new(subcategory: self, school:, academic_year:)
    ResponseRate.create(school:, academic_year:, subcategory: self, student_response_rate: student.rate,
                        teacher_response_rate: teacher.rate, meets_student_threshold: student.meets_student_threshold?,
                        meets_teacher_threshold: teacher.meets_teacher_threshold?)
  end
end
