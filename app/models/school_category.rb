class SchoolCategory < ApplicationRecord

  MIN_RESPONSE_COUNT = 10

  belongs_to :school
  belongs_to :category

  validates_associated :school
  validates_associated :category

  scope :for, -> (school, category) { where(school: school).where(category: category) }
  scope :for_parent_category, -> (school, category=nil) { where(school: school).joins(:category).merge(Category.for_parent(category)) }
  scope :in, -> (year) { where(year: year) }

  scope :valid, -> { where("response_count > #{MIN_RESPONSE_COUNT} or zscore is not null") }

  def answer_index_average
    answer_index_total.to_f / response_count.to_f
  end

  def aggregated_responses(year)
    attempt_data = Attempt.
      created_in(year).
      for_category(category).
      for_school(school).
      select('count(attempts.id) as attempt_count').
      select('count(attempts.answer_index) as response_count').
      select('sum(case when questions.reverse then 6 - attempts.answer_index else attempts.answer_index end) as answer_index_total')[0]

    return {
      attempt_count: attempt_data.attempt_count || 0,
      response_count: attempt_data.response_count || 0,
      answer_index_total: attempt_data.answer_index_total || 0,
      zscore: attempt_data.answer_index_total.nil? ?
        zscore :
        (attempt_data.response_count > MIN_RESPONSE_COUNT ?
          (attempt_data.answer_index_total.to_f / attempt_data.response_count.to_f - 3.to_f) :
          nil)
    }
  end

  def chained_aggregated_responses(year)
    _aggregated_responses = aggregated_responses(year)

    child_school_categories = category.child_categories.collect do |cc|
      SchoolCategory.for(school, cc).valid
    end.flatten.compact

    average_zscore = nil
    zscore_categories = child_school_categories.select { |csc| csc.zscore.present? }
    if zscore_categories.length > 0
      total_zscore = zscore_categories.inject(0) { |total, zc| total + zc.zscore }
      average_zscore = total_zscore / zscore_categories.length
    end

    return {
      attempt_count:
        _aggregated_responses[:attempt_count] +
        child_school_categories.inject(0) { |total, csc| total + csc.attempt_count },
      response_count:
        _aggregated_responses[:response_count] +
        child_school_categories.inject(0) { |total, csc| total + csc.response_count },
      answer_index_total:
        _aggregated_responses[:answer_index_total] +
        child_school_categories.inject(0) { |total, csc| total + csc.answer_index_total },
      zscore: average_zscore.present? ? average_zscore : _aggregated_responses[:zscore]
    }
  end

  def sync_aggregated_responses(year)
    return if ENV['BULK_PROCESS']
    update_attributes(chained_aggregated_responses(year))
    if category.parent_category.present?
      parent_school_category = SchoolCategory.for(school, category.parent_category).in(year).first
      if parent_school_category.nil?
        parent_school_category = SchoolCategory.create(school: school, category: category.parent_category, year: year)
      end
      parent_school_category.sync_aggregated_responses(year)
    end
  end
end
