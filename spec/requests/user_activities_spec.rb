# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe "UserActivities", :type => :request do
  describe "GET /user_activities" do
    it "works! (now write some real specs)" do
      get user_activities_path
      expect(response.status).to be(200)
    end
  end
end
