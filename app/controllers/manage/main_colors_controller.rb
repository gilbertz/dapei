# -*- encoding : utf-8 -*-
class Manage::MainColorsController < Manage::BaseController

  before_filter :set_param_side

  def index
    @main_colors = MainColor.all
  end

  def new
    @main_color = MainColor.new
  end

  def create
    @main_color = MainColor.new(params[:main_color])
    @main_color.save
    redirect_to manage_main_colors_path
  end

  def edit
    @main_color = MainColor.find(params[:id])
  end

  def update
    @main_color = MainColor.find(params[:id])
    @main_color.update_attributes(params[:main_color])
    @main_color.save
    redirect_to manage_main_colors_path
  end

  private
  def set_param_side
    params[:side] = 'manage/areas/sidebar'
  end

end
