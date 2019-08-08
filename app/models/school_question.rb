class SchoolQuestion < ApplicationRecord

  belongs_to :school
  belongs_to :question
  belongs_to :school_category

  validates_associated :school
  validates_associated :question
  validates_associated :school_category

  scope :for, -> (school, question) { where(school_id: school.id, question_id: question.id) }
  scope :in, -> (year) { where(year: year) }

  def sync_attempts
    attempt_data = Attempt.
      joins(:question).
      created_in(school_category.year).
      for_question(question).
      for_school(school).
      select('count(attempts.answer_index) as response_count').
      select('sum(case when questions.reverse then 6 - attempts.answer_index else attempts.answer_index end) as answer_index_total')[0]

    available_responders = school.available_responders_for(question)

    update(
      attempt_count: available_responders,
      response_count: attempt_data.response_count,
      response_rate: attempt_data.response_count.to_f / available_responders.to_f,
      response_total: attempt_data.answer_index_total
    )
  end

end
