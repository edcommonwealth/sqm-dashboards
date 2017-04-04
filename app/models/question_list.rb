class QuestionList < ApplicationRecord

  validates :name, presence: true
  validates :question_ids, presence: true

  attr_accessor :question_id_array
  before_validation :convert_question_id_array
  after_initialize :set_question_id_array

  def questions
    question_id_array.collect { |id| Question.where(id: id).first }.compact
  end

  private

    def convert_question_id_array
      return if question_id_array.blank?
      self.question_ids = question_id_array.reject { |id| id.to_s.empty? }.join(',')
    end

    def set_question_id_array
      return if question_ids.blank?
      self.question_id_array = question_ids.split(',').map(&:to_i)
    end

end
