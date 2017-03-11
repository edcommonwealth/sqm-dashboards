require 'rails_helper'

RSpec.describe AttemptsController, type: :controller do

  let(:valid_session) { {} }

  let(:schedule) { Schedule.new }
  let(:recipient) { Recipient.create(name: 'Recipient', phone: '+11231231234') }
  let(:recipient_schedule) { RecipientSchedule.new }
  let(:question) { Question.new }
  let!(:first_attempt) {
    Attempt.create(
      schedule: schedule,
      recipient: recipient,
      recipient_schedule: recipient_schedule,
      question: question
    )
  }
  let!(:attempt) {
    Attempt.create(
      schedule: schedule,
      recipient: recipient,
      recipient_schedule: recipient_schedule,
      question: question
    )
  }


  describe "POST #twilio" do
    context "with valid params" do
      let(:twilio_attributes) {
        {'MessageSid' => 'ewuefhwieuhfweiuhfewiuhf','AccountSid' => 'wefiuwhefuwehfuwefinwefw','MessagingServiceSid' => 'efwneufhwuefhweiufhiuewhf','From' => '+11231231234','To' => '2223334444','Body' => '3','NumMedia' => '0'}
      }

      it "updates the last attempt by recipient phone number" do
        post :twilio, params: twilio_attributes
        attempt.reload
        expect(attempt.answer_index).to eq(3)
        expect(attempt.twilio_details).to eq(twilio_attributes.with_indifferent_access.to_yaml)
        expect(first_attempt.answer_index).to be_nil
        expect(first_attempt.twilio_details).to be_nil
      end

      it "sends back a message" do
        post :twilio, params: twilio_attributes
        expect(response.body).to eq('Thank you!')
      end
    end
  end
end
