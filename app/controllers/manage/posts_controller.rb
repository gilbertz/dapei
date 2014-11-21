# -*- encoding : utf-8 -*-
#encoding:utf-8
class Manage::PostsController < Manage::BaseController
  before_filter :get_user, :except=>[:like_users]
  before_filter :set_users_for_select, :only => [:edit, :new]
  # GET /posts
  # GET /posts.json
  def index
    #@posts = Kaminari.paginate_array(@user.posts).page(params[:page]).per(10)
    if(@user)
      @posts=@user.posts.order("id desc").page(params[:page]).per(10)
      @total_count=@user.posts_count
      respond_to do |format|
        format.html # index.html.erb
        format.json { render_for_api :public, json: @posts,  :meta => {:result=>"0", :total =>@total_count.to_s } }
      end
    else
      @posts = Post.order("id desc").page(params[:page]).per(15)

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json:{:result=>"1"} }
      end
    end
  end

  # GET /posts/1
  # GET /posts/1.json
  def show
    #if(@user)
    @post = Post.find(params[:id])
    @comments = Kaminari.paginate_array(@post.comments).page(params[:page]).per(5)
    @like_users = @post.likes.page(params[:page]).per(8).map(&:user)
    @items = Item.recommended(@city_id, 1).shuffle
    @shops = Shop.recommended(@city_id).shuffle
    if @user
      session["user_return_to"]=user_post_path(@user,@post)
    end
    respond_to do |format|
      format.html # show.html.erb
      format.json { render_for_api :public,  json: @post, :meta=>{:result=>"0"} }
    end
    #else
    #  respond_to do |format|
    #    format.html # index.html.erb
    #     format.json { render json:{:result=>"1"} }
    #  end
    #end
  end

  # GET /posts/new
  # GET /posts/new.json
  def new
    @post = Post.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render_for_api :public, json: @post, :meta=>{:result=>"0"} }
    end
  end

  # GET /posts/1/edit
  #def edit
  #  @post = Post.find(params[:id])
  #end

  def create

    if params[:user_id]
      user_id = params[:user_id]
    else
      user_id = 1
    end

    @post = Post.new(params[:post].merge(:user_id=> user_id))
    respond_to do |format|
      if @post.save

        redirect_to :back
        return
        #if params[:post_image] and !Photo.correct_img_type?(params[:post_image_type])
        #  format.json { render :json=>{:result=>1, :error=>"wrong format of image format"} }
        #else
        #  Photo.build_photo(current_user, params[:photos],params[:post_image], params[:post_image_type], @post.id, "Post")
        #  format.html { redirect_to user_posts_path(@user), notice: 'Post was successfully created.' }
        #  format.json { render_for_api :public, json: @post, :meta=>{:result=>"0"} }
        #end
      else
        format.html { render action: "new" }
        format.json { render_for_api :error, json: @post, :meta=>{:result=>"1"} }
      end
    end
  end


  def edit
    @post = Post.find(params[:id])
  end

  # PUT /posts/1
  # PUT /posts/1.json
  def update
    @post = Post.find(params[:id])

    respond_to do |format|
      if @post.update_attributes(params[:post])
        format.html { redirect_to manage_posts_path }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    @post = Post.find(params[:id])
    Photo.retract_photos(@post)
    @post.destroy

    respond_to do |format|
      format.html { redirect_to :back }
      format.json { render :json=>{:result=>"0"} }
    end
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

  def next
    @post = Post.find_by_id(params[:post_id])
    next_post = Post.newer(@post)

    respond_to do |format|
      format.html{ redirect_to  user_post_path(@user, next_post) }
    end
  end

  def prev
    @post = Post.find_by_id(params[:post_id])
    previous_post = Post.older(@post)

    respond_to do |format|
      format.html{ redirect_to  user_post_path(@user, previous_post) }
    end
  end

  def photo
    render :layout => false
  end

  def photo_create
    @post = Photo.find(params[:id])

    @post.thumb = params[:photo]
    @post.save

    redirect_to manage_posts_path
  end

  private
  def get_user
    @user=User.find_by_url(params[:user_id])
  end

  def set_users_for_select
    #@users_for_post_selected = [["hisaibaobei", 1]]
    @users_for_post_selected = User.system_users.collect{|u| [u.name, u.id] }
  end
end
