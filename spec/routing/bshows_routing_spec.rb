require "rails_helper"

RSpec.describe BshowsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/bshows").to route_to("bshows#index")
    end

    it "routes to #new" do
      expect(:get => "/bshows/new").to route_to("bshows#new")
    end

    it "routes to #show" do
      expect(:get => "/bshows/1").to route_to("bshows#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/bshows/1/edit").to route_to("bshows#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/bshows").to route_to("bshows#create")
    end

    it "routes to #update" do
      expect(:put => "/bshows/1").to route_to("bshows#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/bshows/1").to route_to("bshows#destroy", :id => "1")
    end

  end
end
