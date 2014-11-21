# -*- encoding : utf-8 -*-
class Saler < ActiveRecord::Base

  #淘宝卖家

  attr_accessible :user_id, :access_token, :refresh_token, :taobao_user_id, :taobao_user_nick


end
