# -*- encoding : utf-8 -*-
#require 'spec_helper'
require_relative '../spec_helper'
describe SearchController, :type => :controller do
  render_views
  context "#to_json" do
    it "includes items" do
      stub_env('production') do
        get "index", :format => :json, :index => "item"
        expect(response).to be_success
        expect(JSON.parse(response.body)["items"].first["item_id"]).not_to be_nil
        expect(JSON.parse(response.body)["items"].length).to be > 0
        JSON.parse(response.body)["items"].each do |item|
          expect(item["price"]).not_to be_nil
          expect(item["origin_price"]).not_to be_nil
        end
      end
    end
  end
end
