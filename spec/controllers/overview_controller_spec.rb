require 'rails_helper'

describe OverviewController, type: :controller do
  include BasicAuthHelper
  let(:school) { create(:school) }
  let(:district) { create(:district) }
  let!(:categories) {
    [create(:category, name: 'Second', sort_index: 2), create(:category, name: 'First', sort_index: 1)]
  }

  it 'fetches categories sorted by sort_index' do
    login_as district
    get :index, params: { school_id:  school.to_param, district_id: district.to_param }
    expect(assigns(:category_presenters).map(&:name)).to eql ['First', 'Second']
  end
end
