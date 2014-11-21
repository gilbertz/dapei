# -*- encoding : utf-8 -*-
#encoding: utf-8
class Manage::AreasController < Manage::BaseController

  def index
    cond = "1=1"
    @q = Area.where(t: 'city', on: true ).where("#{cond}").ransack params[:q]
    @cities = @q.result.page(params[:page]).per(15)
  end

  def edit
    @area = Area.find params[:id]
    render partial: 'form'
  end

  def update
    @area = Area.find params[:id]
    redirect_to [:manage,:areas]
  end

end
