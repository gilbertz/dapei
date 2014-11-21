# -*- encoding : utf-8 -*-
class WelcomeController < ApplicationController
  def m
  end

  def friend_apps
    @friend_apps = FriendApp.order("order_no desc, id desc").all
    render :layout => false
  end

  def friend_weixins
    @friend_apps = FriendApp.order("order_no desc, id desc").all
    render :layout => false
  end

  def go_download
    @friend_app = FriendApp.find(params[:aid])
    @friend_app.increment!(:click_count)
    render :json => {result: 0}
  end

end
