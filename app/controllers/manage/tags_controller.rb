# -*- encoding : utf-8 -*-
class Manage::TagsController < Manage::BaseController

  before_filter :set_param_side

  def index
    @q = Tag.ransack params[:q]
    @tags = @q.result.page(params[:page]).per(15)
  end

  def edit
    @tag = Tag.find(params[:id])
    @sub_categories_for_select = Category.get_all_sub_categories.collect{|c| [c.name, c.id] }
    @categories_for_select = Category.get_first_categories.collect{|c| [c.name, c.id] }
  end

  def new
    @sub_categories_for_select = Category.get_all_sub_categories.collect{|c| [c.name, c.id] }
    @categories_for_select = Category.get_first_categories.collect{|c| [c.name, c.id] }
    @tag = Tag.new
  end

  def create
    @tag = Tag.new(params[:tag])
    @tag.save
    redirect_to manage_tags_path
  end

  def update
    @tag = Tag.find(params[:id])
    @tag.update_attributes(params[:tag])
    @tag.save

    desc_tag = DescTag.where(:category_id => params[:category_id], :tag_id => params[:id]).last

    if desc_tag.blank?
      desc_tag = DescTag.new
    end

    desc_tag.update_attributes(:category_id => params[:category_id], :tag_id => params[:id], :desc => params[:desc], :is_show => params[:is_show])
    desc_tag.save

    redirect_to manage_tags_path
  end

  def get_desc
    desc_tag = DescTag.where(:category_id => params[:category_id], :tag_id => params[:id]).last

    res = desc_tag.try(:desc)

    render :json => {:desc => res, :is_show => desc_tag.try(:is_show)}
  end

  def maps

  end

  private
  def set_param_side
    params[:side] = 'manage/categories/sidebar'
  end

end
