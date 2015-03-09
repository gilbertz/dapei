# -*- encoding : utf-8 -*-
#class ApplicationController < ActionController::Base
class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_current_user 
  before_filter :set_login_status
  before_filter :set_su

  def after_sign_in_path_for(resource)
    if session[:pre_login_controller] and session[:pre_login_action]
      "/#{session[:pre_login_controller]}/#{session[:pre_login_action]}"
    else
      stored_location_for(:user) || current_user_redirect_path
    end
  end


  def load_brand
    @brands = Brand.order("url asc")
  end

  def stored_location_for(resource)
    if (r = session[:user_return_to])
      session[:user_return_to] = nil
      r
    else
      super
    end
  end

  def initialize
    super
    @index = "item"
  end

  def render_state(sym)
    @state = sym.to_s
  end

  def render_success_state
    @state = 'success'
  end


protected
  def set_su
    if params[:suid]
      @su = User.find_by_url params[:suid]
    elsif current_user
      @su = current_user
    end
  end

  def set_current_user
    if params[:token]
      current_user = User.find_by_authentication_token(params[:token])
      User.current_user = current_user if current_user 
    elsif params[:mobile] and params[:code]
      mobile = params[:mobile].strip
      user = User.find_by_mobile(mobile)
      if user and params[:code] == $redis.get(mobile)
        current_user = user
        User.current_user = current_user if current_user 
      end
    else
      User.current_user = current_user if current_user
    end

    if not current_user and params[:code]
      p 'ooooxxx', request.env['omniauth.auth']   
    end

  end

  def set_login_status
    User.current_user = current_user if current_user and not User.current_user
    unless current_user
      cookies.delete :l
      cookies.delete :userid
    end
  end


  def verify_token
    if params[:token] and (params[:token].blank? or params[:token]=="")
      params.delete :token
    end
  end  

  def remove_token
    params.delete :token 
  end

  def render_user_json
    unless @user.is_shop
      render_for_api :public, :json=>@user, :meta=>{:result=>"0", :apply_type => @user.get_type, :user_id => @user.url, :token => @user.get_token }
    else
      render_for_api :user_shop, :json=>@user, :meta=>{:result=>"0", :apply_type => @user.get_type, :token => @user.get_token }
    end
  end


private
  def current_user_redirect_path
    current_user.getting_started? ? getting_started_path : root_path
  end

  def monitor_record
    begin
      monitor_record = MonitorRecord.new
      monitor_record.controller = params[:controller]
      monitor_record.action = params[:action]
      monitor_record.request_type = request.request_method
      monitor_record.request_params = request.fullpath
      monitor_record.original_url = request.original_url
      monitor_record.remote_ip = request.remote_ip
      monitor_record.http_agent = request.env['HTTP_USER_AGENT']
      monitor_record.user_id = current_user.id if current_user
      monitor_record.save
    rescue
      MonitorRecord.create
    end
  end

end
