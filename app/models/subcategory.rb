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
end
