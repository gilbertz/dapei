# -*- encoding : utf-8 -*-
require "spec_helper"

describe BrandTagsController do
  describe "routing" do

    it "routes to #index" do
      get("/brand_tags").should route_to("brand_tags#index")
    end

    it "routes to #new" do
      get("/brand_tags/new").should route_to("brand_tags#new")
    end

    it "routes to #show" do
      get("/brand_tags/1").should route_to("brand_tags#show", :id => "1")
    end

    it "routes to #edit" do
      get("/brand_tags/1/edit").should route_to("brand_tags#edit", :id => "1")
    end

    it "routes to #create" do
      post("/brand_tags").should route_to("brand_tags#create")
    end

    it "routes to #update" do
      put("/brand_tags/1").should route_to("brand_tags#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/brand_tags/1").should route_to("brand_tags#destroy", :id => "1")
    end

  end
end
