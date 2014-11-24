# -*- encoding : utf-8 -*-
class Manage::FriendAppsController < Manage::BaseController

  before_filter :set_param_side

  def new
    @friend_app = FriendApp.new
  end

  def create
    @friend_app = FriendApp.new(params[:friend_app])
    @friend_app.save
    redirect_to manage_friend_apps_path
  end

  def edit
    @friend_app = FriendApp.find(params[:id])
  end

  def update
    @friend_app = FriendApp.find(params[:id])
    @friend_app.update_attributes(params[:friend_app])
    @friend_app.save
    redirect_to manage_friend_apps_path
  end

  def destroy
    @friend_app = FriendApp.find(params[:id])
    @friend_app.destroy
    redirect_to manage_friend_apps_path
  end

  def index
    @friend_apps = FriendApp.order("order_no desc, id desc").all
  end

  private
  def set_param_side
    params[:side] = 'manage/categories/sidebar'
  end


end
