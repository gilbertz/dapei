# -*- encoding : utf-8 -*-
#encoding: utf-8
class Manage::StreetsController < Manage::BaseController
  before_filter :set_params_side

  def index 
    @q = Street.ransack params[:q]
    @streets = @q.result.order("updated_at DESC").page(params[:page]).per(15)
  end

  def edit
    @street = Street.find params[:id]
    render partial: 'form'
  end

  def update
    @street = Street.find params[:id]
    @street.update_attributes params[:street]
    redirect_to [:manage,:streets]
  end

  def destroy
    @street = Street.find params[:id]
    render nothing: true
  end

  private
  def set_params_side
    params[:side] = 'manage/areas/sidebar'
  end
end
