# -*- encoding : utf-8 -*-
class Manage::OrdersController < Manage::BaseController

  before_filter :set_param_side

  def index
    con = "1=1"

    unless params[:number].blank?
      con += " and orders.number = '#{params[:number]}'"
      @number = params[:number]
    end

    unless params[:status].blank? or params[:status] == "0"
      con += " and orders.state = #{params[:status]}"
      @status = params[:status]
    end

    unless params[:name].blank?
      con += " and users.name like '%#{params[:name]}%'"
      @name = params[:name]
    end

    @orders = Order.joins("left join users on users.id = orders.user_id").where(con).order("orders.id desc").page(params[:page])
    @statuses = Order::STATUS.collect{|s| [Order::STATUS_ARG.fetch(s[0]) ,s[1]] }
  end


  def show
    @order = Order.find(params[:id])
  end

  def change
    order = Order.find params[:id]

    if order.send(params[:p], "管理员")

      # unless params[:push_message].blank?
      #   content = params[:push_message]
      #   messages = { aps: { alert: content, sound: "", badge: 1 }, message: {type: "order_update", content: ""} }
      #
      #   p = {
      #       :user_id => order.user_id,
      #       :messages => messages
      #   }
      #   MyBaiduPush::one_push(p)
      # end

      redirect_to :back
      return
    end

    redirect_to :back

  end


  private
  def set_param_side
    @param_side = 'manage/properties/sidebar'
  end
end
