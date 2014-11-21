# -*- encoding : utf-8 -*-
class Manage::TshowsController < Manage::BaseController

  def index
    cond = "1=1"
    params[:brand_id] && cond = "brand_id = #{params[:brand_id]}" 
    @q = Tshow.where(cond).includes([:photos,:brand]).ransack params[:q]
    @tshows = @q.result.order('id desc').page(params[:page]).per(18)
  end

  def edit
    @tshow = Tshow.find params[:id]
    @brands = Brand.order("url asc").collect {|b| [b.name,b.id] }
  end

  def update
    @tshow = Tshow.find params[:id]
    @tshow.update_attributes params[:tshow]
    redirect_to "/manage/tshows"
  end

  def destroy
    @tshow = Tshow.find params[:id]
    render nothing: true
  end

end
