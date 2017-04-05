require 'rails_helper'

RSpec.describe AttemptsController, type: :controller do

  let(:valid_session) { {} }

  let(:schedule) { Schedule.new }
  let(:school) { School.create!(name: 'School') }
  let(:recipient) { school.recipients.create!(name: 'Recipient', phone: '+11231231234') }
  let(:recipient_schedule) { RecipientSchedule.new }
  let(:category) { Category.create!(name: 'Category') }
  let(:question) { create_questions(1, category).first }
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
        expect(attempt.responded_at).to be_present

        expect(first_attempt.answer_index).to be_nil
        expect(first_attempt.twilio_details).to be_nil
        expect(first_attempt.responded_at).to be_nil
      end

      it "sends back a message" do
        post :twilio, params: twilio_attributes
        expect(response.body).to eq """We\'ve registered your response of Option 0:1 C.
To see how others responded to the same question please visit
http://test.host/schools/school/categories/category"""
      end
    end

    context 'with cancel params' do
      let(:twilio_attributes) {
        {'MessageSid' => 'ewuefhwieuhfweiuhfewiuhf','AccountSid' => 'wefiuwhefuwehfuwefinwefw','MessagingServiceSid' => 'efwneufhwuefhweiufhiuewhf','From' => '+11231231234','To' => '2223334444','Body' => 'cAnCel','NumMedia' => '0'}
      }

      it "updates the last attempt by recipient phone number" do
        post :twilio, params: twilio_attributes
        attempt.reload
        expect(attempt.answer_index).to be_nil
        expect(attempt.twilio_details).to eq(twilio_attributes.with_indifferent_access.to_yaml)
        expect(attempt.recipient).to be_opted_out
      end

      it "sends back a message" do
        post :twilio, params: twilio_attributes
        expect(response.body).to eq('Thank you, you have been opted out of these messages and will no longer receive them.')
      end
    end
  end
end
