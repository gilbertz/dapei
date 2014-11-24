# -*- encoding : utf-8 -*-
#encoding: utf-8
class Manage::AppsController < Manage::BaseController

  def index
    params[:side] = 'manage/categories/sidebar'
    @apps = App.all
    @app_infos = AppInfo.all
  end

  def edit
    @app = App.find params[:id]
    render partial: 'form'
  end

  def update
    app = App.find(params[:id])
    app.update_attributes(params[:app])
    app.save
    redirect_to manage_apps_path
  end

  def new
    @app = App.new
    render partial: "form"
  end

  def create
    app = App.new(params[:app])
    app.save
    redirect_to manage_apps_path
  end


end
