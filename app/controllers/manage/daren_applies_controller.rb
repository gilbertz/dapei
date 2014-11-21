# -*- encoding : utf-8 -*-
class Manage::DarenAppliesController < Manage::BaseController

  before_filter :set_param_side

  def about_daren
    render :layout => false
  end

  def user_help
    render :action => :about_daren, :layout => false
  end

  # GET /daren_applies
  # GET /daren_applies.json
  def index

    unless params[:username].blank?
      con = "users.name like '%#{params[:username]}%' or users.nickname like '%#{params[:username]}%'"
    end

    @daren_applies = DarenApply.includes(:user).where(con).where(:status => 1).order("daren_applies.created_at desc").page(params[:page]).per(20)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @daren_applies }
    end
  end

  # GET /daren_applies/1
  # GET /daren_applies/1.json
  def show
    if current_user
      @daren_apply = DarenApply.find_by_user_id( current_user.id )
    end
    if params[:id]
      @daren_apply = DarenApply.find(params[:id])
    end

    respond_to do |format|
      if @daren_apply
        format.html # show.html.erb
        format.json { render_for_api :public, :json => @daren_apply, :meta=>{:result=>"0"} }
      else
        format.json {}
      end
    end
  end


  # GET /daren_applies/new
  # GET /daren_applies/new.json
  def new
    @daren_apply = DarenApply.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @daren_apply }
    end
  end

  # GET /daren_applies/1/edit
  def edit
    @daren_apply = DarenApply.find(params[:id])
  end

  # POST /daren_applies
  # POST /daren_applies.json
  def create
    user_id = current_user.id if current_user
    @daren_apply = DarenApply.find_by_user_id(user_id)
    unless @daren_apply
      @daren_apply = DarenApply.new(params[:daren_apply].merge(:user_id => user_id) )
    else
      @daren_apply.update_attributes(params[:daren_apply].merge(:user_id => user_id)) 
    end
    @daren_apply.status = 1

    respond_to do |format|
      if @daren_apply.save
           current_user.level = 1
           current_user.save
           if params[:image_type] and !Photo.correct_img_type?(params[:image_type])
             format.json { render :json=>{:result=>"1", :error=>"wrong format of image format"} }
           else
             if params[:upload_image_1]
               pid = Photo.build_avatar(current_user, params[:upload_image_1], params[:image_type])
               @daren_apply.photo1_id = pid
             end
             if params[:upload_image_2]
               pid = Photo.build_avatar(current_user, params[:upload_image_2], params[:image_type])
               @daren_apply.photo2_id = pid
             end
             if params[:upload_image_3]
               pid = Photo.build_avatar(current_user, params[:upload_image_3], params[:image_type])
               @daren_apply.photo3_id = pid
             end              
             @daren_apply.save 

             format.html { redirect_to @daren_apply, notice: 'Daren apply was successfully created.' }
             format.json {  render_for_api :public, :json=>@daren_apply, :meta=>{:result=>"0"} }
          end
      else
        format.html { render action: "new" }
        format.json { render json: @daren_apply.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /daren_applies/1
  # PUT /daren_applies/1.json
  def update
    @daren_apply = DarenApply.find(params[:id])
    @user = User.find_by_id(@daren_apply.user_id)
    prev_level = @user.level.to_i
    respond_to do |format|
      if @daren_apply.update_attributes(params[:daren_apply])
        @user.level = @daren_apply.status
        @user.save
        current_level = @user.level.to_i
        if prev_level == 1 and current_level >= 2
          PushNotification.push_review_daren(@user.id)
        end
        format.html { redirect_to [:manage, @daren_apply], notice: 'Daren apply was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @daren_apply.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /daren_applies/1
  # DELETE /daren_applies/1.json
  def destroy
    @daren_apply = DarenApply.find(params[:id])
    @daren_apply.destroy

    respond_to do |format|
      format.html { redirect_to daren_applies_url }
      format.json { head :no_content }
    end
  end

  private
  def set_param_side
    @param_side = 'manage/daren_applies/sidebar'
  end
end
