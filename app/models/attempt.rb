require 'twilio-ruby'

class Attempt < ApplicationRecord

  belongs_to :schedule
  belongs_to :recipient
  belongs_to :recipient_schedule
  belongs_to :question

  def send_message
    twilio_number = ENV['TWILIO_NUMBER']
    client = Twilio::REST::Client.new ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN']

    message = client.messages.create(
      from: twilio_number,
      to:   recipient.phone,
      body: "#{question.text}\n\r#{question.option1}: Reply 1\n\r#{question.option2}: Reply 2\n\r#{question.option3}: Reply 3\n\r#{question.option4}: Reply 4\n\r#{question.option5}: Reply 5"
    )

    update_attributes(sent_at: Time.new, twilio_sid: message.sid)
    recipient.update_attributes(phone: client.account.messages.get(message.sid).to)
  end

end
