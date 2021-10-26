require 'rails_helper'

describe HomeController, type: :controller do
  let!(:categories) {
    [create(:sqm_category, name: 'Second', sort_index: 2), create(:sqm_category, name: 'First', sort_index: 1)]
  }

  it 'fetches categories sorted by sort_index' do
    get :index
    expect(assigns(:categories).map(&:name)).to eql ['First', 'Second']
  end
end
