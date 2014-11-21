# -*- encoding : utf-8 -*-
require 'spec_helper'

describe WelcomeController do

  describe "GET 'm'" do
    it "returns http success" do
      get 'm'
      response.should be_success
    end
  end

end
