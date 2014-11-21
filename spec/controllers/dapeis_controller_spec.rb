# -*- encoding : utf-8 -*-
#require 'spec_helper'
require_relative '../spec_helper'
describe DapeisController, :type => :controller do
  render_views
  context "#to_json" do
    it "includes dapeis" do
      stub_env('production') do
        get "index", :format => :json
        expect(response).to be_success
        expect(JSON.parse(response.body)["dapeis"].first["dapei_id"]).not_to be_nil
        expect(JSON.parse(response.body)["dapeis"].length).to be > 0
      end
    end
  end
end
