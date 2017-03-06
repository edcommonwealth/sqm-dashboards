require 'rails_helper'

RSpec.describe "schedules/index", type: :view do
  before(:each) do
    @question_list = QuestionList.create!(name: 'Parents Questions', question_id_array: [1, 2, 3])

    @school = assign(:school, School.create!(name: 'School'))

    @recipient_list = RecipientList.create!(name: 'Parents', recipient_id_array: [1, 2, 3], school: @school)

    assign(:schedules, [
      Schedule.create!(
        :name => "Name",
        :description => "MyText",
        :school_id => @school.id,
        :frequency_hours => 3,
        :active => false,
        :random => false,
        :recipient_list_id => @recipient_list.id,
        :question_list_id => @question_list.id
      ),
      Schedule.create!(
        :name => "Name",
        :description => "MyText",
        :school_id => @school.id,
        :frequency_hours => 3,
        :active => false,
        :random => true,
        :recipient_list_id => @recipient_list.id,
        :question_list_id => @question_list.id,
      )
    ])
  end

  it "renders a list of schedules" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => @school.name, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 3
    assert_select "tr>td", :text => true.to_s, :count => 1
    assert_select "tr>td", :text => @recipient_list.name, :count => 2
    assert_select "tr>td", :text => @question_list.name, :count => 2
  end
end
