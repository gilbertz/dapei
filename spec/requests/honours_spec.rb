# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe "Honours", :type => :request do
  describe "GET /honours" do
    it "works! (now write some real specs)" do
      get honours_path
      expect(response.status).to be(200)
    end
  end
end
