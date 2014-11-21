# -*- encoding : utf-8 -*-
require "spec_helper"

describe JoinLotteriesController do
  describe "routing" do

    it "routes to #index" do
      get("/join_lotteries").should route_to("join_lotteries#index")
    end

    it "routes to #new" do
      get("/join_lotteries/new").should route_to("join_lotteries#new")
    end

    it "routes to #show" do
      get("/join_lotteries/1").should route_to("join_lotteries#show", :id => "1")
    end

    it "routes to #edit" do
      get("/join_lotteries/1/edit").should route_to("join_lotteries#edit", :id => "1")
    end

    it "routes to #create" do
      post("/join_lotteries").should route_to("join_lotteries#create")
    end

    it "routes to #update" do
      put("/join_lotteries/1").should route_to("join_lotteries#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/join_lotteries/1").should route_to("join_lotteries#destroy", :id => "1")
    end

  end
end
