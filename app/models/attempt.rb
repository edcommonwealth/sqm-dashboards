require 'twilio-ruby'

class Attempt < ApplicationRecord

  belongs_to :schedule
  belongs_to :recipient
  belongs_to :recipient_schedule
  belongs_to :question

  after_save :update_school_categories
  after_commit :update_counts

  scope :for_question, -> (question) { where(question_id: question.id) }
  scope :for_category, -> (category) { joins(:question).merge(Question.for_category(category)) }
  scope :for_school, -> (school) { joins(:recipient).merge(Recipient.for_school(school)) }
  scope :with_response, -> { where('answer_index is not null or open_response_id is not null')}

  def messages
    [
      #question.text,
      "#{question.text}\n\r#{question.option1}: Reply 1\n\r#{question.option2}: Reply 2\n\r#{question.option3}: Reply 3\n\r#{question.option4}: Reply 4\n\r#{question.option5}: Reply 5\n\rReply 'stop' to stop these messages."
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

  private

    def update_school_categories
      school_category = SchoolCategory.for(recipient.school, question.category).first
      if school_category.nil?
        school_category = SchoolCategory.create(school: recipient.school, category: question.category)
      end
      school_category.sync_aggregated_responses
    end

    def update_counts
      recipient.update_attributes(
        attempts_count: recipient.attempts.count,
        responses_count: recipient.attempts.with_response.count
      )
    end

end
