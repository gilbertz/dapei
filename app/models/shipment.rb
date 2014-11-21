# -*- encoding : utf-8 -*-
class Shipment < ActiveRecord::Base

  #快递方式
  belongs_to :order



  Shipment_info = [["韵达快运", "yunda"], ["顺丰速递", "shunfeng"],["圆通快递", "yuantong"], ["申通快递", "shentong"], ["中通快递", "zhongtong"], ["普通快递", "-1"]]

  STATE = ["等待发货", "已发货", "已签收"]


  def cn_state
    STATE[self.state.to_i]
  end

  def expected
    ""
  end


end
