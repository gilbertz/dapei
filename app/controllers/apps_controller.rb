# -*- encoding : utf-8 -*-
class AppsController < ApplicationController
  # GET /apps
  # GET /apps.json
  def index
    cond = "1=1"
    @limit = 20 
    @page = 1
    @limit = params[:limit].to_i if params[:limit]
    @page = params[:page].to_i if params[:page]

    if params[:ios]
      cond = "source_type=2"
    end
    if params[:android]
      cond = "source_type=1"
    end
    @count = App.where(cond).where(:on => true).length
    @apps = App.where(cond).where(:on => true).order("weight desc, created_at desc").paginate(:page=>@page, :per_page=>@limit)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render_for_api :public, :json => @apps, :meta => {:total =>@count, :head_img => User.default_head_img, :bg_img => User.default_bg_img  } }
    end
  end

  # GET /apps/1
  # GET /apps/1.json
  def show
    @app = App.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @app }
    end
  end

  # GET /apps/new
  # GET /apps/new.json
  def new
    @app = App.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @app }
    end
  end

  # GET /apps/1/edit
  def edit
    @app = App.find(params[:id])
  end

  # POST /apps
  # POST /apps.json
  def create
    @app = App.new(params[:app])

    respond_to do |format|
      if @app.save
        format.html { redirect_to @app, notice: 'App was successfully created.' }
        format.json { render json: @app, status: :created, location: @app }
      else
        format.html { render action: "new" }
        format.json { render json: @app.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /apps/1
  # PUT /apps/1.json
  def update
    @app = App.find(params[:id])

    respond_to do |format|
      if @app.update_attributes(params[:app])
        format.html { redirect_to @app, notice: 'App was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @app.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /apps/1
  # DELETE /apps/1.json
  def destroy
    @app = App.find(params[:id])
    @app.destroy

    respond_to do |format|
      format.html { redirect_to apps_url }
      format.json { head :no_content }
    end
  end
end
