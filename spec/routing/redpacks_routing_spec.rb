require "rails_helper"

RSpec.describe RedpacksController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/redpacks").to route_to("redpacks#index")
    end

    it "routes to #new" do
      expect(:get => "/redpacks/new").to route_to("redpacks#new")
    end

    it "routes to #show" do
      expect(:get => "/redpacks/1").to route_to("redpacks#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/redpacks/1/edit").to route_to("redpacks#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/redpacks").to route_to("redpacks#create")
    end

    it "routes to #update" do
      expect(:put => "/redpacks/1").to route_to("redpacks#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/redpacks/1").to route_to("redpacks#destroy", :id => "1")
    end

  end
end
