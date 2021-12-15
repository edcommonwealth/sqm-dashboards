require 'rails_helper'

module Legacy
  RSpec.describe 'legacy/schools/new', type: :view do
    before(:each) do
      assign(:school, School.new(
                        name: 'MyString',
                        district_id: 1
                      ))
    end

    it 'renders new school form' do
      render

      assert_select 'form[action=?][method=?]', legacy_schools_path, 'post' do
        assert_select 'input#school_name[name=?]', 'school[name]'
      end
    end
  end
end
