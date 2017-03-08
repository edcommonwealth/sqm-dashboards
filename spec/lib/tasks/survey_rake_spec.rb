require 'rails_helper'

describe "survey:make_attempts" do
  include_context "rake"

  let(:ready_recipient_schedules)   { double('ready recipient schedules') }
  let(:recipient_schedules)         { double("recipient schedules", ready: []) }
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
    expect(active_schedule).to (receive(:recipient_schedules))
    expect(Schedule).to receive(:active).and_return([active_schedule])
    subject.invoke
  end
end
