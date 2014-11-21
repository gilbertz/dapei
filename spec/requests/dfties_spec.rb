# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe "Dfties", :type => :request do
  describe "GET /dfties" do
    it "works! (now write some real specs)" do
      get dfties_path
      expect(response.status).to be(200)
    end
  end
end
