require 'twilio-ruby'

class Attempt < ApplicationRecord

  belongs_to :schedule
  belongs_to :recipient
  belongs_to :recipient_schedule
  belongs_to :question

  after_save :update_school_categories

  scope :for_category, -> (category) { joins(:question).merge(Question.for_category(category)) }
  scope :for_school, -> (school) { joins(:recipient).merge(Recipient.for_school(school)) }

  def send_message
    twilio_number = ENV['TWILIO_NUMBER']
    client = Twilio::REST::Client.new ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN']

    message = client.messages.create(
      from: twilio_number,
      to:   recipient.phone,
      body: "#{question.text}\n\r#{question.option1}: Reply 1\n\r#{question.option2}: Reply 2\n\r#{question.option3}: Reply 3\n\r#{question.option4}: Reply 4\n\r#{question.option5}: Reply 5"
    )

    update_attributes(sent_at: Time.new, twilio_sid: message.sid)
    recipient.update_attributes(phone: client.messages.get(message.sid).to)
  end

  private

    def update_school_categories
      school_category = SchoolCategory.for(recipient.school, question.category).first
      if school_category.nil?
        school_category = SchoolCategory.create(school: recipient.school, category: question.category)
      end
      # school_category.aggregate_responses
    end

end
