# -*- encoding : utf-8 -*-
class UserActivitiesController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:create]

  # GET /user_activities
  # GET /user_activities.json
  def index
    @user_activities = UserActivity.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render_for_api :public, :json => @user_activities, :meta=>{:result=>"0"} }
    end
  end

  # GET /user_activities/1
  # GET /user_activities/1.json
  def show
    @user_activity = UserActivity.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render_for_api :public, :json => @user_activity, :meta=>{:result=>"0"} }
    end
  end

  # GET /user_activities/new
  # GET /user_activities/new.json
  def new
    @user_activity = UserActivity.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user_activity }
    end
  end

  # GET /user_activities/1/edit
  def edit
    @user_activity = UserActivity.find(params[:id])
  end

  # POST /user_activities
  # POST /user_activities.json
  def create
    #if current_user.check_in
      @user_activity = UserActivity.new(params[:user_activity].merge(:user_id => current_user.id) )
      @ext = {}
      if @user_activity.action == "check_in" and current_user.check_in
        current_user.check_honour
        @ext = {:score =>"10", :check_times =>"3"} 
      end

      respond_to do |format|
        if @user_activity.save
          format.html { redirect_to @user_activity, notice: 'User activity was successfully created.' }
          format.json { render_for_api :public, :json => @user_activity, :meta=>{:result=>"0", :ext_info=>@ext } }
        else
          format.html { render action: "new" }
          format.json { render json: @user_activity.errors, status: :unprocessable_entity }
        end
      end
    #else
    #  render :json => {:result => "1", :success => true}
    #end
  end

  # PUT /user_activities/1
  # PUT /user_activities/1.json
  def update
    @user_activity = UserActivity.find(params[:id])

    respond_to do |format|
      if @user_activity.update_attributes(params[:user_activity])
        format.html { redirect_to @user_activity, notice: 'User activity was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user_activity.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /user_activities/1
  # DELETE /user_activities/1.json
  def destroy
    @user_activity = UserActivity.find(params[:id])
    @user_activity.destroy

    respond_to do |format|
      format.html { redirect_to user_activities_url }
      format.json { head :no_content }
    end
  end
end
