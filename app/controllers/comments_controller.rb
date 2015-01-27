# -*- encoding : utf-8 -*-

class CommentsController < ApplicationController
  before_filter :authenticate_user! , :only => [:create, :destroy]
  load_and_authorize_resource :except => [:new,:create]
  skip_before_filter :verify_authenticity_token, :only => [:create]

  def new
    @comment=Comment.new

    respond_to do |format|
      format.html # new.html.haml
      format.json
    end
  end

  def create
    user = current_user if current_user
    if params[:comment][:user_id]
      u = User.find_by_id( params[:comment][:user_id] )
      user = u if u
    end
    if(params[:comment][:target_type] and params[:comment][:target_id])
      @commentable_type=params[:comment][:target_type].constantize
      @commentable_id=transform(@commentable_type, params[:comment][:target_id])
      if params[:comment][:tuid]
        @tuser = User.find_by_url( params[:comment][:tuid] )
        @tuid = @tuser.id
      end
      trans_params={:comment=>params[:comment][:comment], :commentable_id=>@commentable_id, :commentable_type=>params[:comment][:target_type], :tuid => @tuid}
      @commentable = @commentable_type.find(@commentable_id)
      @comment = @commentable.comments.new(trans_params.merge(:user_id=>user.id))  
    else
      @commentable_type=params[:comment][:commentable_type].constantize
      @commentable_id=params[:comment][:commentable_id]
      @commentable = @commentable_type.find(@commentable_id)
      @comment = @commentable.comments.new(params[:comment].merge(:user_id=>user.id))
    end
    respond_to do |format|
      if @comment.save
        format.html { redirect_to(:back, :notice => '评论创建成功了!') }
        format.json { render_for_api :public, :json => @comment, :meta=>{:result=>"0"} }
      else
        format.html { render :action => "new", :notice=>'宝贝创建失败!' }
        format.json { render_for_api :error, :json=>@comment, :meta=>{:result=>"1"}}
      end
    end
  end


  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy

    respond_to do |format|
      format.html { redirect_to :back }
      format.json {render :json=>{:result=>"0"}}
    end
  end

  def show
    @comment = Comment.find(params[:id])
    @comment.destroy

    respond_to do |format|
      format.html { redirect_to :back}
      format.json { render_for_api :json=>@comment }
    end
  end

  def index
    @limit = 10
    @limit = params[:limit].to_i if params[:limit]
    if(get_commentable)
      p_key = "#{@commentable.class}_#{@commentable.id}_page_#{params[:page]}_limit_#{params[:limit]}"
      #@number = Rails.cache.fetch "comments_index_number_#{p_key}", :expires_in => 3.minutes do
      #  @commentable.comments.count
      #end

      @number = Comment.cache_comments_count_by_target(@commentable)

      #comments = Rails.cache.fetch "comments_index_#{p_key}", :expires_in => 3.minutes do
      #  @commentable.comments.order("created_at desc").page(params[:page]).per(@limit).entries
      #end

      page = 1
      page = params[:page] unless params[:page].blank?

      comments = Comment.cache_comments_by_target(@commentable, page, @limit)

      @comments = Comment.dup(comments)
    end

    respond_to do |format|
      if(@comments)
      #format.html
        format.json {render_for_api :public, :json=>@comments, :meta=>{:result=>"0", :total_count=>@number.to_s, :limit => @limit.to_s }}
      else
        format.json {render :json=>{:result=>"1"}}
      end  
    end 
  end

private

  def get_commentable
    if (params[:shop_id])
      @commentable=Shop.find_by_url(params[:shop_id])
    elsif (params[:item_id] || params[:dapei_id])
      obj_id = params[:item_id] || params[:dapei_id]
      @commentable=Item.by_url(obj_id)
      @commentable=Dapei.get_star unless @commentable
      @commentable=Sku.find_by_id(obj_id) unless @commentable
    elsif (params[:sku_id])
       @commentable=Sku.find_by_id(params[:sku_id])
    elsif (params[:post_id])
      @commentable=Post.find_by_id(params[:post_id])
    elsif (params[:discount_id])
      @commentable=Discount.find_by_id(params[:discount_id])
    elsif (params[:dapei_response_id])
      @commentable=DapeiResponse.find_by_id(params[:dapei_response_id])
    end
    @commentable  
  end

  def transform(target_type, target_id)
    if(target_type==Post or target_type==Matter)
      @target_id=target_id.to_i
    else
      if target_type==Item or target_type==Dapei
        @target_id=target_type.by_url(target_id).id
      else
        @target_id=target_type.find_by_url(target_id).id
      end
    end
    @target_id
  end

end
