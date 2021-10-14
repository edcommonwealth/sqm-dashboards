require 'rails_helper'

RSpec.describe "question_lists/show", type: :view do
  before(:each) do
    @question_list = assign(:question_list, QuestionList.create!(
      :name => "Name",
      :description => "MyText",
      :question_ids => "MyText"
    ))
  end

  it "renders attributes in <p>" do
    render(template: "question_lists/show.html.haml")
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/MyText/)
  end
end
