# -*- encoding : utf-8 -*-
class Manage::DapeiResponsesController < Manage::BaseController
  
  skip_before_filter :verify_authenticity_token, :only => [:create]

  # GET /dapei_responses
  # GET /dapei_responses.json
  def index
    @page = 1
    @limit = 8
    @page = params[:page].to_i if params[:page]
    @limit = params[:limit].to_i if params[:limit]
    cond = "1=1"
    vcond = "1=1"
 
    order = 'created_at desc'
    if params[:order] and params[:order] == 'hot'
      order = 'likes_count + comments_count desc'
    end

    if params[:request_id]
      cond = "request_id=#{params[:request_id]}"
    end
    if params[:user_id]
      user = User.find_by_url( params[:user_id] )
      cond = "user_id=#{user.id}"
    end
    if params[:v]
      vcond = "dapei_id is not null"
    end

    @dapei_responses = DapeiResponse.where(cond).where(vcond).order(order).page(@page).per(@limit)
    @count = DapeiResponse.where(cond).where(vcond).length

    respond_to do |format|
      format.html # index.html.erb
      format.json { render_for_api :public, :json => @dapei_responses, :meta=>{:result=>"0", :total_count=>@count.to_s } }
    end
  end


  #I can go when the old stream goes.
  def like_users
    @target= DapeiResponse.find(params[:id])

    page = 1
    limit = 8
    page = params[:page].to_i if params[:page]
    limit = params[:limit].to_i if params[:limit]
    @users = Like.like_users( @target, params[:page], limit )


    respond_to do |format|
      format.html { render :nothing=>true }
      format.json { render_for_api :public, :json => @users, :meta=>{:result=>"0", :total_count=> @target.likes_count.to_s} }
    end
  end


  # GET /dapei_responses/1
  # GET /dapei_responses/1.json
  def show
    @dapei_response = DapeiResponse.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
       format.json { render_for_api :public, :json => @dapei_response, :meta=>{:result=>"0"} }
    end
  end

  # GET /dapei_responses/new
  # GET /dapei_responses/new.json
  def new
    @dapei_response = DapeiResponse.new
    @dapei_response.request_id = params[:request_id].to_i if params[:request_id]
    @users = User.where("id > 22000").limit(200)
    @users_for_select = @users.collect{|c| [c.name, c.id] }
  
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @dapei_response }
    end
  end

  # GET /dapei_responses/1/edit
  def edit
    @dapei_response = DapeiResponse.find(params[:id])
  end

  # POST /dapei_responses
  # POST /dapei_responses.json
  def create
    @dapei_response = DapeiResponse.new(params[:dapei_response].merge(:user_id => current_user.id) )

    respond_to do |format|
      if @dapei_response.save
        format.html { redirect_to @dapei_response, notice: 'Dapei response was successfully created.' }
        format.json { render_for_api :public, :json => @dapei_response, :meta=>{:result=>"0"} }
      else
        format.html { render action: "new" }
        format.json { render json: @dapei_response.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /dapei_responses/1
  # PUT /dapei_responses/1.json
  def update
    @dapei_response = DapeiResponse.find(params[:id])

    respond_to do |format|
      if @dapei_response.update_attributes(params[:dapei_response])
        format.html { redirect_to @dapei_response, notice: 'Dapei response was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @dapei_response.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /dapei_responses/1
  # DELETE /dapei_responses/1.json
  def destroy
    @dapei_response = DapeiResponse.find(params[:id])
    @dapei_response.destroy

    respond_to do |format|
      format.html { redirect_to :back }
      format.json { head :no_content }
    end
  end
end
