AggregatedResponses = Struct.new(
  :question,
  :category,
  :responses,
  :count,
  :answer_index_total,
  :answer_index_average,
  :most_popular_answer
)

class Question < ApplicationRecord
  belongs_to :category

  has_many :attempts

  validates :text, presence: true
  validates :option1, presence: true
  validates :option2, presence: true
  validates :option3, presence: true
  validates :option4, presence: true
  validates :option5, presence: true

  scope :for_category, -> (category) { where(category: category) }

  enum target_group: [:unknown, :for_students, :for_teachers, :for_parents]

  def source
    target_group.gsub('for_', '')
  end

  def options
    [option1, option2, option3, option4, option5]
  end

  def option_index(answer)
    options.map(&:downcase).map(&:strip).index(answer.downcase.strip)
  end

  def aggregated_responses_for_school(school)
    school_responses = attempts.for_school(school).with_answer.order(id: :asc)
    return unless school_responses.present?

    response_answer_total = school_responses.inject(0) { |total, response| total + response.answer_index }

    histogram = school_responses.group_by(&:answer_index)
    most_popular_answer_index = histogram.to_a.sort_by { |info| info[1].length }.last[0]
    most_popular_answer = send("option#{most_popular_answer_index}")

    AggregatedResponses.new(
      self,
      category,
      school_responses,
      school_responses.length,
      response_answer_total,
      response_answer_total.to_f / school_responses.length.to_f,
      most_popular_answer
    )
  end
end
