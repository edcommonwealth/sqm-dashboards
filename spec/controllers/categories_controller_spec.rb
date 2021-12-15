require 'rails_helper'

describe CategoriesController, type: :controller do
  include BasicAuthHelper
  let(:school) { create(:school) }
  let(:district) { create(:district) }
  let!(:categories) do
    [create(:category, name: 'Second', sort_index: 2), create(:category, name: 'First', sort_index: 1)]
  end

  it 'fetches categories sorted by sort_index' do
    login_as district
    category = categories.first
    get :show, params: { id: category.to_param, school_id: school.to_param, district_id: district.to_param }
    expect(assigns(:categories).map(&:name)).to eql %w[First Second]
  end
end
