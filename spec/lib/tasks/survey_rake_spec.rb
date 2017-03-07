require 'rails_helper'

describe "survey:make_attempts" do
  include_context "rake"

  
  # let(:old_schedule)             { stub("csv data") }
  # let(:paused_schedule)          { stub("csv data") }
  # let(:report)       { stub("generated report", :to_csv => csv) }
  # let(:user_records) { stub("user records for report") }

  before do
    # ReportGenerator.stubs(:generate)
    # UsersReport.stubs(:new => report)
    # User.stubs(:all => user_records)
  end

  it 'should have environment as a prerequisite' do
    expect(subject.prerequisites).to include("environment")
  end

  it "finds all active schedules" do
    subject.invoke
  end
end
