# -*- encoding : utf-8 -*-
class Payment < ActiveRecord::Base

  belongs_to :user
  belongs_to :order

  METHOD = ["支付宝", "微信"]

  before_update :update_order_state, if: Proc.new{|p| p.state.eql?(3)}



  def cn_state
    case state
      when nil; '未初始化'
      when 1;   '交易开启'
      when 2;   '完成支付'
      when 3;   '交易完成'
    end
  end




  private
  def update_order_state
    self.order.pend
    #&& OrderLog.log(order, "支付宝通知：买家完成支付")
  end


end
