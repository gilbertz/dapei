# -*- encoding : utf-8 -*-
#encoding: utf-8
class Manage::MallsController < Manage::BaseController
  before_filter :set_param_side

  def index 
    @cities = Area.online_cities.collect {|c| [c.name, c.id] }
    @q = Mall.includes(:crawler_templates).ransack params[:q]
    @malls = @q.result.page(params[:page]).per(15)
  end

  private
  def set_param_side
    params[:side] = 'manage/areas/sidebar'
  end
end
