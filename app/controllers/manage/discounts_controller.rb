# -*- encoding : utf-8 -*-
#encoding: utf-8
class Manage::DiscountsController < Manage::BaseController

  def index
    @q = Discount.includes(:discountable,).ransack params[:q]
    @discounts = @q.result.order('id desc').page(params[:page]).per(18)
  end

  def new
    @discount = Discount.new
  end

  def create
  end

  def edit
    @discount = Discount.find params[:id]
    render partial: 'form'
  end

  def update
    @discount = Discount.find params[:id]
    @discount.update_attributes params[:discount]
    redirect_to '/manage/discounts'
  end

  def destroy
    @discount = Discount.find params[:id]
    @discount.destroy
    render nothing: true
  end
end
