# -*- encoding : utf-8 -*-
class ShangjiebaAction < ActiveRecord::Base
  attr_accessible :controller_name, :action_name, :request_path, :request_method, :desc
end
