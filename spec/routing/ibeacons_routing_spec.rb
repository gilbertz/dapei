require "rails_helper"

RSpec.describe IbeaconsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/ibeacons").to route_to("ibeacons#index")
    end

    it "routes to #new" do
      expect(:get => "/ibeacons/new").to route_to("ibeacons#new")
    end

    it "routes to #show" do
      expect(:get => "/ibeacons/1").to route_to("ibeacons#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/ibeacons/1/edit").to route_to("ibeacons#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/ibeacons").to route_to("ibeacons#create")
    end

    it "routes to #update" do
      expect(:put => "/ibeacons/1").to route_to("ibeacons#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/ibeacons/1").to route_to("ibeacons#destroy", :id => "1")
    end

  end
end
