require 'rails_helper'

RSpec.describe "recipient_lists/show", type: :view do
  before(:each) do
    @school = assign(:school, School.create!(name: 'School'))
    @recipient_list = assign(:recipient_list, RecipientList.create!(
      :name => "Name",
      :description => "MyText",
      :recipient_ids => "MyText",
      :school_id => @school.id
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/MyText/)
  end
end
