require 'rails_helper'

RSpec.describe "schedules/edit", type: :view do
  before(:each) do
    question_list = QuestionList.create!(name: 'Parents Questions', question_id_array: [1, 2, 3])

    @school = assign(:school, School.create!(name: 'School'))

    recipient_list = RecipientList.create!(name: 'Parents', recipient_id_array: [1, 2, 3], school: @school)

    @schedule = assign(:schedule, Schedule.create!(
      :name => "MyString",
      :description => "MyText",
      :school_id => @school.id,
      :frequency_hours => 1,
      :active => false,
      :random => false,
      :recipient_list_id => recipient_list.id,
      :question_list_id => question_list.id
    ))
  end

  it "renders the edit schedule form" do
    render

    assert_select "form[action=?][method=?]", school_schedule_path(@school, @schedule), "post" do

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
