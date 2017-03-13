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

  def chained_aggregated_responses
    _aggregated_responses = aggregated_responses

    child_school_categories = category.child_categories.collect do |cc|
      SchoolCategory.for(school, cc)
    end.flatten

    return {
      attempt_count:
        _aggregated_responses[:attempt_count] +
        child_school_categories.inject(0) { |total, csc| total + csc.attempt_count },
      response_count:
        _aggregated_responses[:response_count] +
        child_school_categories.inject(0) { |total, csc| total + csc.response_count },
      answer_index_total:
        _aggregated_responses[:answer_index_total] +
        child_school_categories.inject(0) { |total, csc| total + csc.answer_index_total }
    }
  end

  def sync_aggregated_responses
    return if ENV['BULK_PROCESS']
    update_attributes(chained_aggregated_responses)
    if category.parent_category.present?
      SchoolCategory.for(school, category.parent_category).each { |sc| sc.sync_aggregated_responses }
    end
  end
end
