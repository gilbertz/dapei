# -*- encoding : utf-8 -*-
require "spec_helper"

describe DarenAppliesController do
  describe "routing" do

    it "routes to #index" do
      get("/daren_applies").should route_to("daren_applies#index")
    end

    it "routes to #new" do
      get("/daren_applies/new").should route_to("daren_applies#new")
    end

    it "routes to #show" do
      get("/daren_applies/1").should route_to("daren_applies#show", :id => "1")
    end

    it "routes to #edit" do
      get("/daren_applies/1/edit").should route_to("daren_applies#edit", :id => "1")
    end

    it "routes to #create" do
      post("/daren_applies").should route_to("daren_applies#create")
    end

    it "routes to #update" do
      put("/daren_applies/1").should route_to("daren_applies#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/daren_applies/1").should route_to("daren_applies#destroy", :id => "1")
    end

  end
end
