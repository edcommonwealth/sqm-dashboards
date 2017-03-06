require 'rails_helper'

RSpec.describe "schedules/show", type: :view do
  before(:each) do
    @question_list = QuestionList.create!(name: 'Parents Questions', question_id_array: [1, 2, 3])

    @school = assign(:school, School.create!(name: 'School'))

    @recipient_list = RecipientList.create!(name: 'Parents', recipient_id_array: [1, 2, 3], school: @school)

    @schedule = assign(:schedule, Schedule.create!(
      :name => "Name",
      :description => "MyText",
      :school => @school,
      :frequency_hours => 2 * 24 * 7,
      :active => false,
      :random => false,
      :recipient_list => @recipient_list,
      :question_list => @question_list
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/#{@school.name}/)
    expect(rendered).to match(/Every Other Week/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/#{@recipient_list.name}/)
    expect(rendered).to match(/#{@question_list.name}/)
  end
end
