require 'rails_helper'

describe SqmCategoriesController, type: :controller do
  include BasicAuthHelper
  let(:school) { create(:school) }
  let(:district) { create(:district) }
  let!(:categories) {
    [create(:sqm_category, name: 'Second', sort_index: 2), create(:sqm_category, name: 'First', sort_index: 1)]
  }

  it 'fetches categories sorted by sort_index' do
    login_as district
    category = categories.first
    get :show, params: { id: category.to_param, school_id:  school.to_param, district_id: district.to_param }
    expect(assigns(:categories).map(&:name)).to eql ['First', 'Second']
  end
end
