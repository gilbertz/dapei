# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "DarenApplies" do
  describe "GET /daren_applies" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get daren_applies_path
      response.status.should be(200)
    end
  end
end
