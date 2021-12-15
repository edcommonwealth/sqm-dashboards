require 'rails_helper'

describe HomeController, type: :controller do
  let!(:categories) do
    [create(:category, name: 'Second', sort_index: 2), create(:category, name: 'First', sort_index: 1)]
  end

  it 'fetches categories sorted by sort_index' do
    get :index
    expect(assigns(:categories).map(&:name)).to eql %w[First Second]
  end
end
