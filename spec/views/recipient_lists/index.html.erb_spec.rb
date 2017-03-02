require 'rails_helper'

RSpec.describe "recipient_lists/index", type: :view do
  before(:each) do
    @school = assign(:school, School.create!(name: 'School'))

    assign(:recipient_lists, [
      RecipientList.create!(
        :name => "Name",
        :description => "MyText",
        :recipient_ids => "1,2,3",
        :school_id => @school.id
      ),
      RecipientList.create!(
        :name => "Name",
        :description => "MyText",
        :recipient_ids => "2,3,4",
        :school_id => @school.id
      )
    ])
  end

  it "renders a list of recipient_lists" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "1,2,3".to_s, :count => 1
    assert_select "tr>td", :text => "2,3,4".to_s, :count => 1
  end
end
