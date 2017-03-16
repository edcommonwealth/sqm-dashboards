require 'rails_helper'

RSpec.describe "recipients/index", type: :view do
  before(:each) do
    @school = assign(:school, School.create!(
      name: 'School'
    ))

    assign(:recipients, [
      Recipient.create!(
        :name => "Name",
        :phone => "Phone",
        :gender => "Gender",
        :race => "Race",
        :ethnicity => "Ethnicity",
        :home_language_id => 2,
        :income => "Income",
        :opted_out => false,
        :school_id => @school.id
      ),
      Recipient.create!(
        :name => "Name",
        :phone => "Phone",
        :gender => "Gender",
        :race => "Race",
        :ethnicity => "Ethnicity",
        :home_language_id => 2,
        :income => "Income",
        :opted_out => false,
        :school_id => @school.id
      )
    ])
  end

  it "renders a list of recipients" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "Phone".to_s, :count => 2
    assert_select "tr>td", :text => "Gender".to_s, :count => 2
    assert_select "tr>td", :text => "Race".to_s, :count => 2
    assert_select "tr>td", :text => "Ethnicity".to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => "Income".to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
    assert_select "tr>td", :text => @school.id.to_s, :count => 2
  end
end
