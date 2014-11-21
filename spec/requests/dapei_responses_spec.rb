# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe "DapeiResponses", :type => :request do
  describe "GET /dapei_responses" do
    it "works! (now write some real specs)" do
      get dapei_responses_path
      expect(response.status).to be(200)
    end
  end
end
