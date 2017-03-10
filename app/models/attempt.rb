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
      body: question.text
    )

    puts message.inspect
    puts message.try(:Sid)

    update_attributes(sent_at: Time.new)
  end

end
