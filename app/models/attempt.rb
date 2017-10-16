require 'twilio-ruby'

class Attempt < ApplicationRecord

  belongs_to :schedule
  belongs_to :recipient
  belongs_to :recipient_schedule
  belongs_to :question
  belongs_to :student

  after_save :update_school_categories
  after_commit :update_counts

  scope :for_question, -> (question) { where(question_id: question.id) }
  scope :for_recipient, -> (recipient) { where(recipient_id: recipient.id) }
  scope :for_student, -> (student) { where(student_id: student.id) }
  scope :for_category, -> (category) { joins(:question).merge(Question.for_category(category)) }
  scope :for_school, -> (school) { joins(:recipient).merge(Recipient.for_school(school)) }
  scope :with_answer, -> { where('answer_index is not null or open_response_id is not null')}
  scope :with_no_answer, -> { where('answer_index is null and open_response_id is null')}
  scope :not_yet_responded, -> { where(responded_at: nil) }
  scope :last_sent, -> { order(sent_at: :desc) }

  def messages
    child_specific = student.present? ? " (for #{student.name})" : ''

    cancel_text = "\nSkip question: skip\nStop all questions: stop"

    [
      "#{question.text}#{child_specific}",
      "#{question.option1}: Reply 1\n#{question.option2}: 2\n#{question.option3}: 3\n#{question.option4}: 4\n#{question.option5}: 5"
    ]
  end

  def send_message
    twilio_number = ENV['TWILIO_NUMBER']
    client = Twilio::REST::Client.new ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN']

    sids = []
    messages.each do |message|
      sids << client.messages.create(
        from: twilio_number,
        to:   recipient.phone,
        body: message
      ).sid
    end

    update_attributes(sent_at: Time.new, twilio_sid: sids.join(','))
    recipient.update_attributes(phone: client.messages.get(sids.last).to)
  end

  def response
    return 'No Answer Yet' if answer_index.blank?
    question.options[answer_index - 1]
  end

  def save_response(answer_index: nil, twilio_details: nil, responded_at: Time.new)
    update_attributes(
      answer_index: answer_index,
      twilio_details: twilio_details,
      responded_at: responded_at
    )

    if recipient_schedule.queued_question_ids.present?
      recipient_schedule.update(next_attempt_at: Time.new)
    end
  end

  private

    def update_school_categories
      return if ENV['BULK_PROCESS']
      school_category = SchoolCategory.for(recipient.school, question.category).first
      if school_category.nil?
        school_category = SchoolCategory.create(school: recipient.school, category: question.category)
      end
      school_category.sync_aggregated_responses
    end

    def update_counts
      return if ENV['BULK_PROCESS']
      recipient.update_counts
    end

end
