# -*- encoding : utf-8 -*-
#encoding: utf-8
class Manage::BrandTagsController < Manage::BaseController
  before_filter :set_param_side

  def index
    @q = BrandTag.ransack params[:q]
    @brand_tags = @q.result.page(params[:page]).per(100)
  end

  def edit
    @brand_tag = BrandTag.find params[:id]
    render partial: 'form'
  end

  def new
    @brand_tag = BrandTag.new
    render partial: 'form'
  end

  def create
    @brand_tag = BrandTag.new
    @brand_tag.save
    redirect_to [:manage,:brand_tags]
  end

  def update
    @brand_tag = BrandTag.find params[:id]
    @brand_tag.update_attributes params[:brand_tag]
    redirect_to [:manage,:brand_tags]
  end

  def destroy
    @brand_tag = BrandTag.find params[:id]
    render nothing: true
  end

  private
  def set_param_side
    @param_side = 'manage/brands/sidebar'
  end
end
