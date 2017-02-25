require 'rails_helper'

RSpec.describe "recipients/show", type: :view do
  before(:each) do
    @recipient = assign(:recipient, Recipient.create!(
      :name => "Name",
      :phone => "Phone",
      :gender => "Gender",
      :race => "Race",
      :ethnicity => "Ethnicity",
      :home_language_id => 2,
      :income => "Income",
      :opted_out => false,
      :school_id => 3
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/Phone/)
    expect(rendered).to match(/Gender/)
    expect(rendered).to match(/Race/)
    expect(rendered).to match(/Ethnicity/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/Income/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/3/)
  end
end
