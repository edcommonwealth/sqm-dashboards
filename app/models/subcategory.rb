class Subcategory < ActiveRecord::Base
  belongs_to :category

  has_many :measures

  def score(school:, academic_year:)
    scores = measures.includes([:survey_items]).map do |measure|
      measure.score(school:, academic_year:).average
    end
    scores = scores.reject(&:nil?)
    scores.average
  end

  def student_response_rate(school:, academic_year:)
    @student_response_rate ||= Hash.new do |memo|
      memo[[school, academic_year]] = StudentResponseRate.new(subcategory: self, school:, academic_year:)
    end

    @student_response_rate[[school, academic_year]]
  end

  def teacher_response_rate(school:, academic_year:)
    @teacher_response_rate ||= Hash.new do |memo|
      memo[[school, academic_year]] = TeacherResponseRate.new(subcategory: self, school:, academic_year:)
    end

    @teacher_response_rate[[school, academic_year]]
  end
end
