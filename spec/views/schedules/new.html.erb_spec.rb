require 'rails_helper'

RSpec.describe "schedules/new", type: :view do
  before(:each) do
    question_list = QuestionList.create!(name: 'Parents Questions', question_id_array: [1, 2, 3])

    @school = assign(:school, School.create!(name: 'School'))

    recipient_list = RecipientList.create!(name: 'Parents', recipient_id_array: [1, 2, 3], school: @school)

    assign(:schedule, Schedule.new(
      :name => "MyString",
      :description => "MyText",
      :school => @school,
      :frequency_hours => 1,
      :active => false,
      :random => false,
      :recipient_list => @recipient_list,
      :question_list => @question_list
    ))
  end

  it "renders new schedule form" do
    render

    assert_select "form[action=?][method=?]", school_schedules_path(@school), "post" do

      assert_select "input#schedule_name[name=?]", "schedule[name]"

      assert_select "textarea#schedule_description[name=?]", "schedule[description]"

      assert_select "select[name=?]", "schedule[frequency_hours]"

      assert_select "input#schedule_active[name=?]", "schedule[active]"

      assert_select "input#schedule_random[name=?]", "schedule[random]"

      assert_select "select[name=?]", "schedule[recipient_list_id]"

      assert_select "select[name=?]", "schedule[question_list_id]"
    end
  end
end
