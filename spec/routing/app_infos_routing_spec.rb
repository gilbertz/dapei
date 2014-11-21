# -*- encoding : utf-8 -*-
require "spec_helper"

describe AppInfosController do
  describe "routing" do

    it "routes to #index" do
      get("/app_infos").should route_to("app_infos#index")
    end

    it "routes to #new" do
      get("/app_infos/new").should route_to("app_infos#new")
    end

    it "routes to #show" do
      get("/app_infos/1").should route_to("app_infos#show", :id => "1")
    end

    it "routes to #edit" do
      get("/app_infos/1/edit").should route_to("app_infos#edit", :id => "1")
    end

    it "routes to #create" do
      post("/app_infos").should route_to("app_infos#create")
    end

    it "routes to #update" do
      put("/app_infos/1").should route_to("app_infos#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/app_infos/1").should route_to("app_infos#destroy", :id => "1")
    end

  end
end
