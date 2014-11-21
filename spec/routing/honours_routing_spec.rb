# -*- encoding : utf-8 -*-
require "rails_helper"

RSpec.describe HonoursController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/honours").to route_to("honours#index")
    end

    it "routes to #new" do
      expect(:get => "/honours/new").to route_to("honours#new")
    end

    it "routes to #show" do
      expect(:get => "/honours/1").to route_to("honours#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/honours/1/edit").to route_to("honours#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/honours").to route_to("honours#create")
    end

    it "routes to #update" do
      expect(:put => "/honours/1").to route_to("honours#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/honours/1").to route_to("honours#destroy", :id => "1")
    end

  end
end
