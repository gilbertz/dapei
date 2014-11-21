# -*- encoding : utf-8 -*-
class Manage::CellTypesController < Manage::BaseController


  before_filter :set_param_side
  before_filter :get_typeset_types, only: [:new, :edit]


  def new
    @cell_type = CellType.new
  end

  def create
    @cell_type = CellType.new(params[:cell_type])
    @cell_type.save

    redirect_to manage_typesets_path
  end

  def edit
    @cell_type = CellType.find(params[:id])
  end

  def update
    @cell_type = CellType.find(params[:id])
    @cell_type.update_attributes(params[:cell_type])
    @cell_type.save
    redirect_to manage_cell_types_path
  end

  def index
    # @cell_types = CellType.includes(:set_cells, :typeset_type).all
    @typeset_types = TypesetType.all
  end

  private
  def set_param_side
    params[:side] = 'manage/areas/sidebar'
  end


  def get_typeset_types
    @typeset_types_for_select = TypesetType.for_select
  end

end
