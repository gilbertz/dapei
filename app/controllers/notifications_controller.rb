# -*- encoding : utf-8 -*-

class NotificationsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :get_mailbox
  before_filter :get_actor

  def index
    @number=@mailbox.notifications.count
    @notifications = @mailbox.notifications.not_trashed.page(params[:page]).per(10)
    @gnotifications = []
    @notifications.each do |n|
      @gnotifications << n if n.notified_object
    end
    
    @group_days = @gnotifications.group_by{|note| I18n.l((note.created_at).to_date) }
    read_all
    respond_to do |format|
      format.html 
      format.json{render_for_api :public, :json=>@gnotifications, :api_cache => 10.minutes, :meta=>{:result=>"0", :total_count=>@number.to_s}}
    end
  end

  def index1
    @number=@mailbox.notifications.count
    @notifications = @mailbox.notifications.not_trashed.page(params[:page]).per(10)
    @gnotifications = []
    @notifications.each do |n|
      @gnotifications << n if n.notified_object and not n.notified_object.instance_of?(Discount)
    end

    @group_days = @gnotifications.group_by{|note| I18n.l((note.created_at).to_date) }
    read_all
    respond_to do |format|
      format.html
      format.json{render_for_api :notify, :json=>@gnotifications, :api_cache => 10.minutes, :meta=>{:result=>"0", :total_count=>@number.to_s}}
    end
  end

 
  def notify
    @number = @mailbox.notifications.count
    @notifications = @mailbox.notifications.not_trashed.page(params[:page]).per(10)
    @gnotifications = []
    @notifications.each do |n|
      if n.notified_object.instance_of?(User)
        created_at =  n.notified_object.created_at
        uid = 1 
        n.notified_object = Post.new(:user_id => uid, :title => '欢迎加入搭配秘书, 点下面查看搭配帮助', :link => 'http://www.shangjieba.com/sjb/daren_applies/user_help')
        n.notified_object.created_at = created_at
        n.notified_object.image_url = "http://1251008728.cdn.myqcloud.com/1251008728/2014/05/29/dapei.png"
        @gnotifications << n
      else
        next if n.notified_object_type == 'Comment' and n.notified_object and n.get_url.blank?
        next if n.notified_object_type == 'Like' and n.notified_object and n.get_url.blank?
        @gnotifications << n if n.notified_object and not n.notified_object.instance_of?(Discount) 
      end
    end

    @group_days = @gnotifications.group_by{|note| I18n.l((note.created_at).to_date) }
    read_all
    respond_to do |format|
      format.html
      format.json{render_for_api :notify, :json=>@gnotifications, :api_cache => 10.minutes, :meta=>{:result=>"0", :total_count=>@number.to_s}}
    end
  end

  
  def update
    if params[:read].present?
      if params[:read].eql?("Read")
        @notification.mark_as_read(@actor)
      elsif params[:read].eql?("Unread")
        @notification.mark_as_unread(@actor)
      end
    end
    @notifications = @mailbox.notifications.not_trashed.page(params[:page]).per(10)
    respond_to do |format|
      format.html {render :action => :index}
      format.json 
    end
  end

  def update_all
    read_all
    @notifications = @mailbox.notifications.not_trashed.page(params[:page]).per(10)
    respond_to do |format|
      format.html {render :action => :index}
      format.json {render :json=>{:result=>"0"}} 
    end
  end


  private

  def read_all
    current_user.set_notify_read

    #@unread_nots= @mailbox.notifications(:read=>false).page(params[:page]).per(10)
    @unread_nots= @mailbox.notifications(:read=>false)
    # The following need to be optimized.
    #@unread_nots= @mailbox.notifications(:read=>false)
    @unread_nots.each do |n|
      if n.is_unread?(@actor) 
        n.mark_as_read(@actor)
      end
    end
  end

  def get_mailbox
    @mailbox = current_user.mailbox
  end

  def get_actor
    @actor =  current_user
  end

end
