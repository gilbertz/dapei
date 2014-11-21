# -*- encoding : utf-8 -*-
require "rails_helper"

RSpec.describe DapeiResponsesController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/dapei_responses").to route_to("dapei_responses#index")
    end

    it "routes to #new" do
      expect(:get => "/dapei_responses/new").to route_to("dapei_responses#new")
    end

    it "routes to #show" do
      expect(:get => "/dapei_responses/1").to route_to("dapei_responses#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/dapei_responses/1/edit").to route_to("dapei_responses#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/dapei_responses").to route_to("dapei_responses#create")
    end

    it "routes to #update" do
      expect(:put => "/dapei_responses/1").to route_to("dapei_responses#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/dapei_responses/1").to route_to("dapei_responses#destroy", :id => "1")
    end

  end
end
