# -*- encoding : utf-8 -*-
class Manage::AllTagsController < Manage::BaseController

  before_filter :set_param_side

  def new
    @all_tag = AllTag.new
  end

  def create
    @all_tag = AllTag.new(params[:all_tag])
    @all_tag.save
    redirect_to manage_all_tags_path
  end

  def index
    @q = AllTag.search(params[:q])

    @all_tags = @q.result.page(params[:page]).per(20)
  end

  def edit
    @all_tag = AllTag.find(params[:id])
  end

  def update
    @all_tag = AllTag.find(params[:id])
    @all_tag.update_attributes(params[:all_tag])
    @all_tag.save
    redirect_to manage_all_tags_path
  end

  def destroy
    @all_tag = AllTag.find(params[:id])
    @all_tag.destroy
    redirect_to :back
  end

  private
  def set_param_side
    params[:side] = 'manage/areas/sidebar'
  end

end
