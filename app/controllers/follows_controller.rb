# -*- encoding : utf-8 -*-
class FollowsController < ApplicationController
  before_filter :authenticate_user! , :only => [:new, :create, :destroy]
  before_filter :get_followable, :only => [:new, :create, :destroy]
  skip_before_filter :verify_authenticity_token, :only => [:create, :destroy]

  def new
    follow=Follow.new
    respond_to do |format|
        format.html 
        format.json
    end
  end

  def create
    if(@followable)
      @follow=current_user.follow(@followable)

      respond_to do |format|
          format.html { redirect_to(:back, :notice => 'Follow成功了!') }
          format.json {render_for_api :public, :json => @follow,  :meta => {:result=>"0"}} 
      end
    else
      respond_to do |format|
          format.html
          format.json {render :json=>{:result=>"1"}}
      end
    end
  end

  def destroy
    current_user.stop_following(@followable)
    respond_to do |format|
        format.html { redirect_to(:back, :notice => '解除Follow成功了!') }
        format.json {render :json=>{:result=>"0"}}
    end
  end

  #一键关注
  def create_many
    logger.info params[:ids]
    logger.info "===================="
    logger.info params[:ids].count

    u_ids = params[:ids]

    users = User.where(:url => u_ids).all

    c_ids = users.collect{|u| u.id}

    follows = Follow.where(:follower_id => current_user.id, :followable_id => c_ids, :followable_type => "User").all

    unless follows.blank?
      already_ids = follows.collect{|f| f.followable_id }
      c_ids = c_ids - already_ids
    end

    puts c_ids.count
    puts "================"

    c_ids.each do |i|
      Follow.create(:followable_id => i, :follower_id => current_user.id, :followable_type => "User", :follower_type => "User")
    end

    render :json => {result: 0}
  end

  #一键取消
  def destroy_many
    logger.info params[:ids]
    logger.info "===================="
    logger.info params[:ids].count

    u_ids = params[:ids]

    users = User.where(:url => u_ids).all

    c_ids = users.collect{|u| u.id}

    Follow.where(:followable_id => c_ids, :follower_id => current_user.id, :followable_type => "User", :follower_type => "User").destroy_all
    render :json => {result: 0}
  end

private

  def get_followable
    if(params[:shop_id])
      @shop=Shop.find_by_url(params[:shop_id])
      @followable_type=Shop
      @followable_id=@shop.id
    elsif params[:user_id]
      @user=User.find_by_url(params[:user_id])  
      @followable_type=User
      @followable_id=@user.id
    else
      render :nothing=>true
      return     
    end 
    @followable=@followable_type.find(@followable_id)
  end

end
