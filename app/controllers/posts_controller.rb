# -*- encoding : utf-8 -*-
#encoding:utf-8
class PostsController < ApplicationController

  def index
    per_page = params[:per_page] || 10

    per_page = 20

    @posts = Post.cache_posts(params[:page], per_page)
  end


  def new_index
    per_page = params[:per_page] || 10

    @posts = Post.cache_posts(params[:page], per_page)
  end


  def like_users
    @target= Post.find(params[:id])
    @likes = @target.likes.page(params[:page]).per(8)
    @users = @likes.map(&:user)

    respond_to do |format|
      format.html { render :nothing=>true }
      format.json { render_for_api :public, :json => @users, :meta=>{:result=>"0"} }
    end
  end

  def show
    @post = Post.find(params[:id])
    @title = @post.title
    render :layout => "layouts/post"
  end

end
