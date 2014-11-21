# -*- encoding : utf-8 -*-
class Manage::TypesetTypesController < Manage::BaseController

  before_filter :set_param_side

  def new
    @typeset_type = TypesetType.new
  end


  def create
    @typeset_type = TypesetType.new(params[:typeset_type])
    @typeset_type.save
    redirect_to new_manage_typeset_type_path
  end


  def index
    @typeset_types = TypesetType.all
  end


  private
  def set_param_side
    params[:side] = 'manage/areas/sidebar'
  end

end
