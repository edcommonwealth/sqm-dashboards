require 'rails_helper'

describe "survey:attempt_qustions" do
  include_context "rake"

  let(:ready_recipient_schedule)   { double('ready recipient schedule', attempt_question: nil) }
  let(:recipient_schedules)         { double("recipient schedules", ready: [ready_recipient_schedule]) }
  let(:active_schedule)             { double("active schedule", recipient_schedules: recipient_schedules) }

  before do
    # ReportGenerator.stubs(:generate)
    # UsersReport.stubs(:new => report)
    # User.stubs(:all => user_records)
  end

  it 'should have environment as a prerequisite' do
    expect(subject.prerequisites).to include("environment")
  end

  it "finds all active schedules" do
    expect(ready_recipient_schedule).to receive(:attempt_question)
    expect(active_schedule).to receive(:recipient_schedules)
    expect(Schedule).to receive(:active).and_return([active_schedule])
    subject.invoke
  end
end
