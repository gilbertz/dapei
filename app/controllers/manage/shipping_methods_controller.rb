# -*- encoding : utf-8 -*-
class Manage::ShippingMethodsController < Manage::BaseController

  before_filter :set_param_side


  def index
    params[:menu] = manage_shipping_methods_path
    @q = ShippingMethod.ransack params[:q]
    @shipping_methods = @q.result.order('id desc').page params[:page]
  end

  def new
    @shipping_method = ShippingMethod.new
    render partial: 'form'
  end

  def create
    shipping_method = ShippingMethod.new shipping_method_params
    shipping_method.save
    redirect_to manage_shipping_methods_path
  end

  def edit
    @shipping_method = ShippingMethod.find params[:id]
    render partial: 'form'
  end

  def update
    shipping_method = ShippingMethod.find params[:id]
    shipping_method.update_attributes shipping_method_params
    redirect_to manage_shipping_methods_path
  end

  def invert_state
    shipping_method = ShippingMethod.find params[:id]
    shipping_method.invert_state
    render json: {msg: 'ok', val: shipping_method.reload.cn_state}
  end

  def set_default
    shipping_method = ShippingMethod.find params[:id]
    shipping_method.update_attributes(default: true)
    render json: {msg: 'ok', val: shipping_method.reload.cn_default}
  end

  def destroy
    shipping_method = ShippingMethod.find params[:id]
    shipping_method.destroy
    render nothing: true
  end

  private
  def shipping_method_params
    params[:shipping_method]
  end

  def set_param_side
    params[:side] = 'manage/properties/sidebar'
  end

end
