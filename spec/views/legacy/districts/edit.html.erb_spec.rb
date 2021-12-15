require 'rails_helper'

module Legacy
  RSpec.describe 'legacy/districts/edit', type: :view do
    before(:each) do
      @district = assign(:district, Legacy::District.create!(
                                      name: 'MyString',
                                      state_id: 1
                                    ))
    end

    it 'renders the edit district form' do
      render

      assert_select 'form[action=?][method=?]', district_path(@district), 'post' do
        assert_select 'input#district_name[name=?]', 'district[name]'

        assert_select 'input#district_state_id[name=?]', 'district[state_id]'
      end
    end
  end
end
