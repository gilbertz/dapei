# -*- encoding : utf-8 -*-
class Manage::TypesetsController < Manage::BaseController

  before_filter :set_param_side
  before_filter :get_typeset_types, only: [:new, :edit]


  def index
    @typesets = Typeset.all

    unless params[:list].blank?
      render :template => "manage/typesets/list"
      return
    end

  end

  def new
    @typeset = Typeset.new
  end

  def create
    @typeset = Typeset.new(params[:typeset])
    @typeset.save
    redirect_to manage_typesets_path
  end

  def edit
    @typeset = Typeset.find(params[:id])
  end

  def update
    @typeset = Typeset.find(params[:id])
    @typeset.update_attributes(params[:typeset])
    @typeset.save
    redirect_to manage_typesets_path
  end

  private
  def set_param_side
    params[:side] = 'manage/areas/sidebar'
  end

  def get_typeset_types
    @typeset_types_for_select = TypesetType.for_select
  end

end
