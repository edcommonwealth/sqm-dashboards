require 'rails_helper'

RSpec.describe AttemptsController, type: :controller do

  let(:valid_session) { {} }

  let(:schedule) { Schedule.new }
  let(:recipient) { Recipient.new }
  let(:recipient_schedule) { RecipientSchedule.new }
  let(:question) { Question.new }
  let!(:attempt) {
    Attempt.create(
      schedule: schedule,
      recipient: recipient,
      recipient_schedule: recipient_schedule,
      question: question
    )
  }

  describe "PUT #update" do
    context "with valid params" do
      let(:twilio_attributes) {
        {'MessageSid' => 'ewuefhwieuhfweiuhfewiuhf','AccountSid' => 'wefiuwhefuwehfuwefinwefw','MessagingServiceSid' => 'efwneufhwuefhweiufhiuewhf','From' => '1112223333','To' => '2223334444','Body' => '3','NumMedia' => '0'}
      }

      it "updates the requested question_list" do
        put :update, params: twilio_attributes.merge(id: attempt.to_param), session: valid_session
        attempt.reload
        expect(attempt.answer_index).to eq(3)
        expect(attempt.twilio_details).to eq(twilio_attributes.with_indifferent_access.to_yaml)
      end

      it "redirects to the question_list" do
        put :update, params: twilio_attributes.merge(id: attempt.to_param), session: valid_session
        expect(response.body).to eq('Thank you!')
      end
    end
  end
end
