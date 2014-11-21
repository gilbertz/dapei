# -*- encoding : utf-8 -*-
#encoding: utf-8
class Manage::FlinksController < Manage::BaseController

  def index
    params[:side] = 'manage/areas/sidebar'
    @q = Flink.ransack params[:q]
    @flinks = @q.result.page(params[:page]).per(18)
  end

  def new
    @flink = Flink.new
    render partial: 'form'
  end

  def create
    flink = Flink.new params[:flink]
    flink.save
    redirect_to [:manage,:flinks]
  end

  def edit
    @flink = Flink.find params[:id]
    render partial: 'form'
  end

  def update
    flink = Flink.find params[:id]
    flink.update_attributes params[:flink]
    redirect_to [:manage,:flinks]
  end

  def destroy
    flink = Flink.find params[:id]
    flink.destroy
    render nothing: true
  end
end
