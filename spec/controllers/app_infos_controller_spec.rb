# -*- encoding : utf-8 -*-
require 'spec_helper'

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

describe AppInfosController do

  # This should return the minimal set of attributes required to create a valid
  # AppInfo. As you add validations to AppInfo, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { { "code" => "MyString" } }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # AppInfosController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET index" do
    it "assigns all app_infos as @app_infos" do
      app_info = AppInfo.create! valid_attributes
      get :index, {}, valid_session
      assigns(:app_infos).should eq([app_info])
    end
  end

  describe "GET show" do
    it "assigns the requested app_info as @app_info" do
      app_info = AppInfo.create! valid_attributes
      get :show, {:id => app_info.to_param}, valid_session
      assigns(:app_info).should eq(app_info)
    end
  end

  describe "GET new" do
    it "assigns a new app_info as @app_info" do
      get :new, {}, valid_session
      assigns(:app_info).should be_a_new(AppInfo)
    end
  end

  describe "GET edit" do
    it "assigns the requested app_info as @app_info" do
      app_info = AppInfo.create! valid_attributes
      get :edit, {:id => app_info.to_param}, valid_session
      assigns(:app_info).should eq(app_info)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new AppInfo" do
        expect {
          post :create, {:app_info => valid_attributes}, valid_session
        }.to change(AppInfo, :count).by(1)
      end

      it "assigns a newly created app_info as @app_info" do
        post :create, {:app_info => valid_attributes}, valid_session
        assigns(:app_info).should be_a(AppInfo)
        assigns(:app_info).should be_persisted
      end

      it "redirects to the created app_info" do
        post :create, {:app_info => valid_attributes}, valid_session
        response.should redirect_to(AppInfo.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved app_info as @app_info" do
        # Trigger the behavior that occurs when invalid params are submitted
        AppInfo.any_instance.stub(:save).and_return(false)
        post :create, {:app_info => { "code" => "invalid value" }}, valid_session
        assigns(:app_info).should be_a_new(AppInfo)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        AppInfo.any_instance.stub(:save).and_return(false)
        post :create, {:app_info => { "code" => "invalid value" }}, valid_session
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested app_info" do
        app_info = AppInfo.create! valid_attributes
        # Assuming there are no other app_infos in the database, this
        # specifies that the AppInfo created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        AppInfo.any_instance.should_receive(:update_attributes).with({ "code" => "MyString" })
        put :update, {:id => app_info.to_param, :app_info => { "code" => "MyString" }}, valid_session
      end

      it "assigns the requested app_info as @app_info" do
        app_info = AppInfo.create! valid_attributes
        put :update, {:id => app_info.to_param, :app_info => valid_attributes}, valid_session
        assigns(:app_info).should eq(app_info)
      end

      it "redirects to the app_info" do
        app_info = AppInfo.create! valid_attributes
        put :update, {:id => app_info.to_param, :app_info => valid_attributes}, valid_session
        response.should redirect_to(app_info)
      end
    end

    describe "with invalid params" do
      it "assigns the app_info as @app_info" do
        app_info = AppInfo.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        AppInfo.any_instance.stub(:save).and_return(false)
        put :update, {:id => app_info.to_param, :app_info => { "code" => "invalid value" }}, valid_session
        assigns(:app_info).should eq(app_info)
      end

      it "re-renders the 'edit' template" do
        app_info = AppInfo.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        AppInfo.any_instance.stub(:save).and_return(false)
        put :update, {:id => app_info.to_param, :app_info => { "code" => "invalid value" }}, valid_session
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested app_info" do
      app_info = AppInfo.create! valid_attributes
      expect {
        delete :destroy, {:id => app_info.to_param}, valid_session
      }.to change(AppInfo, :count).by(-1)
    end

    it "redirects to the app_infos list" do
      app_info = AppInfo.create! valid_attributes
      delete :destroy, {:id => app_info.to_param}, valid_session
      response.should redirect_to(app_infos_url)
    end
  end

end
