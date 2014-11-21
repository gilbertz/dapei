# -*- encoding : utf-8 -*-
class Honour < ActiveRecord::Base
  attr_accessible :active, :img, :img_1, :small_image, :name, :url, :user_id, :honour_id

  scope :active, lambda {
    where( :active=>true ).where( "user_id is null")
  }
end
