# -*- encoding : utf-8 -*-
class AppInfosController < ApplicationController
  # GET /app_infos
  # GET /app_infos.json
  def index
    @app_infos = AppInfo.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @app_infos }
    end
  end

  # GET /app_infos/1
  # GET /app_infos/1.json
  def show
    @app_info = AppInfo.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @app_info }
    end
  end

  # GET /app_infos/new
  # GET /app_infos/new.json
  def new
    @app_info = AppInfo.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @app_info }
    end
  end

  # GET /app_infos/1/edit
  def edit
    @app_info = AppInfo.find(params[:id])
  end

  # POST /app_infos
  # POST /app_infos.json
  def create
    @app_info = AppInfo.new(params[:app_info])

    respond_to do |format|
      if @app_info.save
        format.html { redirect_to @app_info, notice: 'App info was successfully created.' }
        format.json { render json: @app_info, status: :created, location: @app_info }
      else
        format.html { render action: "new" }
        format.json { render json: @app_info.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /app_infos/1
  # PUT /app_infos/1.json
  def update
    @app_info = AppInfo.find(params[:id])

    respond_to do |format|
      if @app_info.update_attributes(params[:app_info])
        format.html { redirect_to @app_info, notice: 'App info was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @app_info.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /app_infos/1
  # DELETE /app_infos/1.json
  def destroy
    @app_info = AppInfo.find(params[:id])
    @app_info.destroy

    respond_to do |format|
      format.html { redirect_to app_infos_url }
      format.json { head :no_content }
    end
  end
end
