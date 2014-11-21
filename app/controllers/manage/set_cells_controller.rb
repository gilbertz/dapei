# -*- encoding : utf-8 -*-
class Manage::SetCellsController < Manage::BaseController


  before_filter :set_param_side


  def new

    @set_cell = SetCell.where(:typeset_id => params[:typeset_id], :cell_type_id => params[:cell_type_id]).order("id desc").first

    if @set_cell.blank?
      @set_cell = SetCell.new(:typeset_id => params[:typeset_id], :cell_type_id => params[:cell_type_id])
    end

    @cell_type = CellType.find(params[:cell_type_id])

    @tags_for_select = [["选择标签", 0]]+Tag.all.collect{|t| [t.name, t.id] }

    # render :partial => "form"

  end

  def create
    @set_cell = SetCell.new(params[:set_cell])
    @set_cell.save

    redirect_to manage_typesets_path
  end

  def update
    @set_cell = SetCell.find(params[:id])

    @set_cell.update_attributes(params[:set_cell])

    @set_cell.save

    redirect_to manage_typesets_path
  end


  private
  def set_param_side
    params[:side] = 'manage/areas/sidebar'
  end

end
