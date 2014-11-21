# -*- encoding : utf-8 -*-
#encoding: utf-8
class Manage::UsersController < Manage::BaseController
  before_filter :set_param_side

  def index
    @q = User.ransack params[:q]
    order = "dapei_score desc"
    if params[:order] == "level"
      order = "level desc"
    elsif params[:order] == "ca"
      order = "created_at desc"
    elsif params[:order] == "sa"
      order = "updated_at desc"
    elsif params[:order] == "dc"
      order = "dapeis_count desc"
    else
      order = "dapei_score desc"
    end

    @users = @q.result.order(order).page(params[:page]).per(50)
  end


  def set_black
    u = User.find(params[:id])

    if u.level != -1
      u.mark_as_ad
    else
      u.cancel_as_ad
    end

    redirect_to :back
  end


  def set_v
    u = User.find(params[:id])
    if u.level.to_i < 2
      u.level = 2
    else
      u.level = 0
    end
    u.save

    redirect_to :back
  end


  private
  def set_param_side
    params[:side] = 'manage/areas/sidebar'
  end
end
