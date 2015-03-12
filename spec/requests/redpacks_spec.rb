require 'rails_helper'

RSpec.describe "Redpacks", :type => :request do
  describe "GET /redpacks" do
    it "works! (now write some real specs)" do
      get redpacks_path
      expect(response).to have_http_status(200)
    end
  end
end
