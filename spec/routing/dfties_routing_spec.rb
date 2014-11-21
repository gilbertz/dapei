# -*- encoding : utf-8 -*-
require "rails_helper"

RSpec.describe DftiesController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/dfties").to route_to("dfties#index")
    end

    it "routes to #new" do
      expect(:get => "/dfties/new").to route_to("dfties#new")
    end

    it "routes to #show" do
      expect(:get => "/dfties/1").to route_to("dfties#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/dfties/1/edit").to route_to("dfties#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/dfties").to route_to("dfties#create")
    end

    it "routes to #update" do
      expect(:put => "/dfties/1").to route_to("dfties#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/dfties/1").to route_to("dfties#destroy", :id => "1")
    end

  end
end
