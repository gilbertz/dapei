# -*- encoding : utf-8 -*-
class OrderLog < ActiveRecord::Base
  belongs_to :order
  belongs_to :user

  class << self
    def log(order, action, user=nil)
      create(order: order, user: user, action: action)
    end
  end

end
