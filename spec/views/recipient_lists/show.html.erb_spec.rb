require 'rails_helper'

RSpec.describe "recipient_lists/show", type: :view do
  before(:each) do
    @school = assign(:school, School.create!(name: 'School'))

    recipients = ['Jared Cosulich', 'Lauren Cosulich'].collect do |name|
      @school.recipients.create!(name: name)
    end

    @recipient_list = assign(:recipient_list, RecipientList.create!(
      :name => "Name",
      :description => "MyText",
      :recipient_id_array => recipients.map(&:id),
      :school_id => @school.id
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/Jared Cosulich/)
    expect(rendered).to match(/Lauren Cosulich/)
  end
end
