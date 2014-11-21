# -*- encoding : utf-8 -*-
class BrandTagsController < ApplicationController
  # GET /brand_tags
  # GET /brand_tags.json
  def index
    @brand_tags = BrandTag.order("type_id asc")
 
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @brand_tags }
    end
  end

  # GET /brand_tags/1
  # GET /brand_tags/1.json
  def show
    @brand_tag = BrandTag.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @brand_tag }
    end
  end

  # GET /brand_tags/new
  # GET /brand_tags/new.json
  def new
    @brand_tag = BrandTag.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @brand_tag }
    end
  end

  # GET /brand_tags/1/edit
  def edit
    @brand_tag = BrandTag.find(params[:id])
  end

  # POST /brand_tags
  # POST /brand_tags.json
  def create
    @brand_tag = BrandTag.new(params[:brand_tag])

    respond_to do |format|
      if @brand_tag.save
        format.html { redirect_to @brand_tag, notice: 'Brand tag was successfully created.' }
        format.json { render json: @brand_tag, status: :created, location: @brand_tag }
      else
        format.html { render action: "new" }
        format.json { render json: @brand_tag.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /brand_tags/1
  # PUT /brand_tags/1.json
  def update
    @brand_tag = BrandTag.find(params[:id])

    respond_to do |format|
      if @brand_tag.update_attributes(params[:brand_tag])
        format.html { redirect_to @brand_tag, notice: 'Brand tag was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @brand_tag.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /brand_tags/1
  # DELETE /brand_tags/1.json
  def destroy
    @brand_tag = BrandTag.find(params[:id])
    @brand_tag.destroy

    respond_to do |format|
      format.html { redirect_to brand_tags_url }
      format.json { head :no_content }
    end
  end
end
