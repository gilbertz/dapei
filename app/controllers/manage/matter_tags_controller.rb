# -*- encoding : utf-8 -*-
#encoding: utf-8
class Manage::MatterTagsController < Manage::BaseController
  before_filter :set_param_side

  def index
    @q = MatterTag.ransack params[:q]
    @matter_tags = @q.result.order('id desc').page(params[:page]).per(15)
  end

  private
  def set_param_side
    @param_side = 'manage/categories/sidebar'
  end
end
