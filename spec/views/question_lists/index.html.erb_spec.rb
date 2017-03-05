require 'rails_helper'

RSpec.describe "question_lists/index", type: :view do
  before(:each) do
    assign(:question_lists, [
      QuestionList.create!(
        :name => "Name",
        :description => "MyText",
        :question_ids => "1,2,3"
      ),
      QuestionList.create!(
        :name => "Name",
        :description => "MyText",
        :question_ids => "2,3,4"
      )
    ])
  end

  it "renders a list of question_lists" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "1,2,3".to_s, :count => 1
    assert_select "tr>td", :text => "2,3,4".to_s, :count => 1
  end
end
