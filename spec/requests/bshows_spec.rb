require 'rails_helper'

RSpec.describe "Bshows", :type => :request do
  describe "GET /bshows" do
    it "works! (now write some real specs)" do
      get bshows_path
      expect(response).to have_http_status(200)
    end
  end
end
