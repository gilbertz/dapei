# -*- encoding : utf-8 -*-
module Manage::OrdersHelper

  def info_btns
    [
        [:delivery, '确定？', 'btn-info', 'icon-eject', '发货', :confirmed],
        [:confirm , '确定？', 'btn-success', 'icon-ok', '确认', :pending],
        [:expire, '确定？', 'btn-warning', 'icon-trash', '过期', :waiting],
        [:cancel, '取消订单？', 'btn-danger', 'icon-off', '取消', :waiting]
    ].select{|i| i[5].eql?(@order.invert_status) }.inject("") do |sum, arr|

      if arr[5] == :pending
        sum << submit_tag(arr[4], confirm: "确定?", class: "btn #{arr[2]} changeState")
        sum << link_to("<i class='icon-off icon-white'></i>取消".html_safe, change_manage_order_path(@order, p: "cancel"), remote: true, class: "btn btn-danger changeState", data: {confirm: "取消订单？"})
      else
        sum << link_to("<i class='#{arr[3]} icon-white'></i>#{arr[4]}".html_safe, change_manage_order_path(@order, p: arr[0]), remote: true, class: "btn #{arr[2]} changeState", data: {confirm: arr[1]})
      end

      sum << hidden_field_tag(:p, arr[0])
    end
  end

end
