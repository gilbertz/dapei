# -*- encoding : utf-8 -*-
require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

RSpec.describe HonoursController, :type => :controller do

  # This should return the minimal set of attributes required to create a valid
  # Honour. As you add validations to Honour, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    skip("Add a hash of attributes valid for your model")
  }

  let(:invalid_attributes) {
    skip("Add a hash of attributes invalid for your model")
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # HonoursController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET index" do
    it "assigns all honours as @honours" do
      honour = Honour.create! valid_attributes
      get :index, {}, valid_session
      expect(assigns(:honours)).to eq([honour])
    end
  end

  describe "GET show" do
    it "assigns the requested honour as @honour" do
      honour = Honour.create! valid_attributes
      get :show, {:id => honour.to_param}, valid_session
      expect(assigns(:honour)).to eq(honour)
    end
  end

  describe "GET new" do
    it "assigns a new honour as @honour" do
      get :new, {}, valid_session
      expect(assigns(:honour)).to be_a_new(Honour)
    end
  end

  describe "GET edit" do
    it "assigns the requested honour as @honour" do
      honour = Honour.create! valid_attributes
      get :edit, {:id => honour.to_param}, valid_session
      expect(assigns(:honour)).to eq(honour)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Honour" do
        expect {
          post :create, {:honour => valid_attributes}, valid_session
        }.to change(Honour, :count).by(1)
      end

      it "assigns a newly created honour as @honour" do
        post :create, {:honour => valid_attributes}, valid_session
        expect(assigns(:honour)).to be_a(Honour)
        expect(assigns(:honour)).to be_persisted
      end

      it "redirects to the created honour" do
        post :create, {:honour => valid_attributes}, valid_session
        expect(response).to redirect_to(Honour.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved honour as @honour" do
        post :create, {:honour => invalid_attributes}, valid_session
        expect(assigns(:honour)).to be_a_new(Honour)
      end

      it "re-renders the 'new' template" do
        post :create, {:honour => invalid_attributes}, valid_session
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      let(:new_attributes) {
        skip("Add a hash of attributes valid for your model")
      }

      it "updates the requested honour" do
        honour = Honour.create! valid_attributes
        put :update, {:id => honour.to_param, :honour => new_attributes}, valid_session
        honour.reload
        skip("Add assertions for updated state")
      end

      it "assigns the requested honour as @honour" do
        honour = Honour.create! valid_attributes
        put :update, {:id => honour.to_param, :honour => valid_attributes}, valid_session
        expect(assigns(:honour)).to eq(honour)
      end

      it "redirects to the honour" do
        honour = Honour.create! valid_attributes
        put :update, {:id => honour.to_param, :honour => valid_attributes}, valid_session
        expect(response).to redirect_to(honour)
      end
    end

    describe "with invalid params" do
      it "assigns the honour as @honour" do
        honour = Honour.create! valid_attributes
        put :update, {:id => honour.to_param, :honour => invalid_attributes}, valid_session
        expect(assigns(:honour)).to eq(honour)
      end

      it "re-renders the 'edit' template" do
        honour = Honour.create! valid_attributes
        put :update, {:id => honour.to_param, :honour => invalid_attributes}, valid_session
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested honour" do
      honour = Honour.create! valid_attributes
      expect {
        delete :destroy, {:id => honour.to_param}, valid_session
      }.to change(Honour, :count).by(-1)
    end

    it "redirects to the honours list" do
      honour = Honour.create! valid_attributes
      delete :destroy, {:id => honour.to_param}, valid_session
      expect(response).to redirect_to(honours_url)
    end
  end

end
