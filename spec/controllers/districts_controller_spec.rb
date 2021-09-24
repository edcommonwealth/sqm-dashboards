require 'rails_helper'

RSpec.describe DistrictsController, type: :controller do

  # This should return the minimal set of attributes required to create a valid
  # District. As you add validations to District, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    {name: 'Milford'}
  }

  let(:invalid_attributes) {
    {name: ''}
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # DistrictsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET #index" do
    it "assigns all districts as @districts" do
      get :index, params: {}, session: valid_session
      expect(assigns(:districts)).to eq(District.all.alphabetic)
    end
  end

  describe "GET #show" do
    it "assigns the requested district as @district" do
      district = District.create! valid_attributes
      get :show, params: {id: district.to_param}, session: valid_session
      expect(assigns(:district)).to eq(district)
    end
  end

  describe "GET #new" do
    it "assigns a new district as @district" do
      get :new, params: {}, session: valid_session
      expect(assigns(:district)).to be_a_new(District)
    end
  end

  describe "GET #edit" do
    it "assigns the requested district as @district" do
      district = District.create! valid_attributes
      get :edit, params: {id: district.to_param}, session: valid_session
      expect(assigns(:district)).to eq(district)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new District" do
        expect {
          post :create, params: {district: valid_attributes}, session: valid_session
        }.to change(District, :count).by(1)
      end

      it "assigns a newly created district as @district" do
        post :create, params: {district: valid_attributes}, session: valid_session
        expect(assigns(:district)).to be_a(District)
        expect(assigns(:district)).to be_persisted
      end

      it "redirects to the created district" do
        post :create, params: {district: valid_attributes}, session: valid_session
        expect(response).to redirect_to(District.last)
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved district as @district" do
        post :create, params: {district: invalid_attributes}, session: valid_session
        expect(assigns(:district)).to be_a_new(District)
      end

      it "re-renders the 'new' template" do
        post :create, params: {district: invalid_attributes}, session: valid_session
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) {
        {name: 'New District'}
      }

      it "updates the requested district" do
        district = District.create! valid_attributes
        put :update, params: {id: district.to_param, district: new_attributes}, session: valid_session
        district.reload
        expect(district.name).to eq('New District')
      end

      it "assigns the requested district as @district" do
        district = District.create! valid_attributes
        put :update, params: {id: district.to_param, district: valid_attributes}, session: valid_session
        expect(assigns(:district)).to eq(district)
      end

      it "redirects to the district" do
        district = District.create! valid_attributes
        put :update, params: {id: district.to_param, district: valid_attributes}, session: valid_session
        expect(response).to redirect_to(district)
      end
    end

    context "with invalid params" do
      it "assigns the district as @district" do
        district = District.create! valid_attributes
        put :update, params: {id: district.to_param, district: invalid_attributes}, session: valid_session
        expect(assigns(:district)).to eq(district)
      end

      it "re-renders the 'edit' template" do
        district = District.create! valid_attributes
        put :update, params: {id: district.to_param, district: invalid_attributes}, session: valid_session
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested district" do
      district = District.create! valid_attributes
      expect {
        delete :destroy, params: {id: district.to_param}, session: valid_session
      }.to change(District, :count).by(-1)
    end

    it "redirects to the districts list" do
      district = District.create! valid_attributes
      delete :destroy, params: {id: district.to_param}, session: valid_session
      expect(response).to redirect_to(districts_url)
    end
  end

end
