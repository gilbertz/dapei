# -*- encoding : utf-8 -*-
class DevicesController < ApplicationController

  def register
    @user_id=params[:device][:user_id]
    @udid=params[:device][:udid]
    @device_token=params[:device][:token]
    #if !@user_id
      if @udid and @device_token
         @dev=Device.where(:udid =>@udid).first()
         if @dev
           @dev.update_attributes(params[:device])
         else
           @dev=Device.new(params[:device])
           @dev.save
         end
         respond_to do |format|
           #format.html # new.html.haml
           format.json {render_for_api :public, :json => @dev, :meta => {:result=>0 }}
         end
      else
        respond_to do |format|
          #format.html # new.html.haml
          format.json{render :json=>{:result=>"1", :error=>"udid and device token could not be null!"}}
        end
      end
    #end
  end
end
