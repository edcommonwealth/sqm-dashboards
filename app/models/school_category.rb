class SchoolCategory < ApplicationRecord

  belongs_to :school
  belongs_to :category

  scope :for, -> (school, category) { where(school: school).where(category: category) }

  def aggregated_responses
    attempt_data = Attempt.
      for_category(category).
      for_school(school).
      select('count(attempts.id) as attempt_count').
      select('count(attempts.answer_index) as response_count').
      select('sum(attempts.answer_index) as answer_index_total')[0]

    return {
      attempt_count: attempt_data.attempt_count,
      response_count: attempt_data.response_count,
      answer_index_total: attempt_data.answer_index_total
    }
  end

  def aggregate_responses
    return if ENV['BULK_PROCESS']

  end
end
