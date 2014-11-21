# -*- encoding : utf-8 -*-
class CrawlerTemplatesController < ApplicationController
  before_filter :load_brand, :only=>[:edit]
  before_filter :load_brand1, :only=>[:new]
  before_filter :load_mall, :only=>[:edit, :new]
  before_filter :get_brand, :only => [:create, :update]
  before_filter :get_mall, :only => [:create, :update]

  # GET /crawler_templates
  # GET /crawler_templates.json
  def index
    @crawler_templates = CrawlerTemplate.order("mall_id asc, updated_at desc")

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @crawler_templates }
    end
  end

  # GET /crawler_templates/1
  # GET /crawler_templates/1.json
  def show
    @crawler_template = CrawlerTemplate.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @crawler_template }
    end
  end

  # GET /crawler_templates/new
  # GET /crawler_templates/new.json
  def new
    @crawler_template = CrawlerTemplate.new
    if params[:mall_id]
      @crawler_template.mall_id = params[:mall_id]
    end
    
    if params[:brand_id]
      @crawler_template.brand_id = params[:brand_id]
    end

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @crawler_template }
    end
  end

  # GET /crawler_templates/1/edit
  def edit
    @crawler_template = CrawlerTemplate.find(params[:id])
  end

  # POST /crawler_templates
  # POST /crawler_templates.json
  def create
    @crawler_template = CrawlerTemplate.new(params[:crawler_template])

    respond_to do |format|
      if @crawler_template.save
        @crawler_template.sync_mall_shop
        format.html { redirect_to new_crawler_template_path, notice: 'Crawler template was successfully created.' }
        format.json { render json: @crawler_template, status: :created, location: @crawler_template }
      else
        format.html { render action: "new" }
        format.json { render json: @crawler_template.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /crawler_templates/1
  # PUT /crawler_templates/1.json
  def update
    @crawler_template = CrawlerTemplate.find(params[:id])

    respond_to do |format|
      if @crawler_template.update_attributes(params[:crawler_template])
        @crawler_template.sync_mall_shop
        format.html { redirect_to crawler_templates_url, notice: 'Crawler template was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @crawler_template.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /crawler_templates/1
  # DELETE /crawler_templates/1.json
  def destroy
    @crawler_template = CrawlerTemplate.find(params[:id])
    @crawler_template.destroy

    respond_to do |format|
      format.html { redirect_to crawler_templates_url }
      format.json { head :no_content }
    end
  end

private
  def load_brand1
    brands = Brand.order("url asc")
    @brands = []
    brands.each do |b|
      if not b.crawler_templates or b.crawler_templates.length == 0
        @brands << b
      end
    end
  end

  def get_brand
    if params[:crawler_template][:brand_id]
       brand =  Brand.find_by_id( params[:crawler_template][:brand_id] )
       params[:crawler_template] = params[:crawler_template].merge(:brand_name =>brand.name ) if brand
    end
  end

  def get_mall
    if params[:crawler_template][:mall_id]
       mall =  Mall.find_by_id( params[:crawler_template][:mall_id] )
    end
  end


end
