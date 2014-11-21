# -*- encoding : utf-8 -*-
require "spec_helper"

describe AskForDapeisController do
  describe "routing" do

    it "routes to #index" do
      get("/ask_for_dapeis").should route_to("ask_for_dapeis#index")
    end

    it "routes to #new" do
      get("/ask_for_dapeis/new").should route_to("ask_for_dapeis#new")
    end

    it "routes to #show" do
      get("/ask_for_dapeis/1").should route_to("ask_for_dapeis#show", :id => "1")
    end

    it "routes to #edit" do
      get("/ask_for_dapeis/1/edit").should route_to("ask_for_dapeis#edit", :id => "1")
    end

    it "routes to #create" do
      post("/ask_for_dapeis").should route_to("ask_for_dapeis#create")
    end

    it "routes to #update" do
      put("/ask_for_dapeis/1").should route_to("ask_for_dapeis#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/ask_for_dapeis/1").should route_to("ask_for_dapeis#destroy", :id => "1")
    end

  end
end
