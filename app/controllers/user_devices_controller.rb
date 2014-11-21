# -*- encoding : utf-8 -*-
class UserDevicesController < ApplicationController
  # GET /user_devices
  # GET /user_devices.json
  def index
    @page = 1
    @limit = 8
    @page = params[:page].to_i if params[:page]
    @limit = params[:limit].to_i if params[:limit]
    @user_devices = UserDevice.page(@page).per(@limit)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @user_devices }
    end
  end

  # GET /user_devices/1
  # GET /user_devices/1.json
  def show
    @user_device = UserDevice.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user_device }
    end
  end

  # GET /user_devices/new
  # GET /user_devices/new.json
  def new
    @user_device = UserDevice.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user_device }
    end
  end

  # GET /user_devices/1/edit
  def edit
    @user_device = UserDevice.find(params[:id])
  end

  # POST /user_devices
  # POST /user_devices.json
  def create
    @user_device = UserDevice.find_by_channel_id( params[:user_device][:channel_id] )
    if current_user
        params[:user_device] = params[:user_device].merge(:user_id=>current_user.id)
    end
    if @user_device
      @user_device.update_attributes( params[:user_device] )
    else
      @user_device = UserDevice.new( params[:user_device] )
    end

    respond_to do |format|
      if @user_device.save
        format.html { redirect_to @user_device, notice: 'User device was successfully created.' }
        format.json {
          render_for_api :public, :json => @user_device, :meta=>{:result=>"0"}
        }
      else
        format.html { render action: "new" }
        format.json { render json: @user_device.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /user_devices/1
  # PUT /user_devices/1.json
  def update
    @user_device = UserDevice.find(params[:id])

    respond_to do |format|
      if @user_device.update_attributes(params[:user_device])
        format.html { redirect_to @user_device, notice: 'User device was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user_device.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /user_devices/1
  # DELETE /user_devices/1.json
  def destroy
    @user_device = UserDevice.find(params[:id])
    @user_device.destroy

    respond_to do |format|
      format.html { redirect_to user_devices_url }
      format.json { head :no_content }
    end
  end
end
