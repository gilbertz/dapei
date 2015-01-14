# -*- encoding : utf-8 -*-

class RecommendsController < ApplicationController
  # GET /recommends
  # GET /recommends.json
  def index
    #@recommends = Recommend.all
    @recommend_streets=Recommend.where(:recommends => {:recommended_type => "Street"}).order("updated_at desc").limit(20)
    @recommend_discounts=Recommend.where('recommends.recommended_type' => "Discount").order("created_at desc").limit(20)
    @recommend_brands=Recommend.where('recommends.recommended_type' => "Brand").order("created_at desc").limit(20)
    @recommend_dapeis=Recommend.joins("INNER JOIN items ON items.id = recommends.recommended_id ").where('recommends.recommended_type' => "Item").where("items.category_id=1001").order("created_at desc").limit(20)
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @recommends }
    end
  end

  # GET /recommends/1
  # GET /recommends/1.json
  def show
    @recommend = Recommend.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @recommend }
    end
  end

  # GET /recommends/new
  # GET /recommends/new.json
  def new
    @recommend = Recommend.new

    respond_to do |format|
      format.html
      format.json { render json: @recommend }
    end
  end

  # GET /recommends/1/edit
  def edit
    @recommend = Recommend.find(params[:id])
  end

  # POST /recommends
  # POST /recommends.json
  def create
    if params[:recommend][:recommended_type] =="Item"
      @object_id=Item.find_by_url(params[:recommend][:recommended_id]).id
    elsif params[:recommend][:recommended_type] =="Matter" 
      @object_id=Matter.find_by_id(params[:recommend][:recommended_id]).id
    elsif params[:recommend][:recommended_type] =="Brand"
      @object_id=Brand.find_by_id(params[:recommend][:recommended_id]).id
    else
      @object_id=params[:recommend][:recommended_id].to_i
    end

    params[:recommend][:recommended_id]=@object_id
    @recommend = Recommend.new(params[:recommend]) unless \
      Recommend.find_by_recommended_type_and_recommended_id(params[:recommend][:recommended_type], @object_id )

    respond_to do |format|
      if @recommend and @recommend.save
        format.json { render json: @recommend, status: :created, location: @recommend }
      else
        format.json { render json: @recommend.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /recommends/1
  # PUT /recommends/1.json
  def update
    @recommend = Recommend.find(params[:id])

    respond_to do |format|
      if @recommend.update_attributes(params[:recommend])
        format.html { redirect_to @recommend, notice: 'Recommend was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @recommend.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /recommends/1
  # DELETE /recommends/1.json
  def destroy
    @recommend = Recommend.find(params[:id])
    @recommend.destroy

    respond_to do |format|
      format.html { render :text=>"删除成功"  }
      format.json { head :no_content }
    end
  end

end
