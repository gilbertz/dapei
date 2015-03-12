class BshowsController < ApplicationController
  # GET /bshows
  # GET /bshows.json
  def index
    @bshows = Bshow.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @bshows }
    end
  end

  # GET /bshows/1
  # GET /bshows/1.json
  def show
    @bshow = Bshow.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @bshow }
    end
  end

  # GET /bshows/new
  # GET /bshows/new.json
  def new
    @bshow = Bshow.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @bshow }
    end
  end

  # GET /bshows/1/edit
  def edit
    @bshow = Bshow.find(params[:id])
  end

  # POST /bshows
  # POST /bshows.json
  def create
    @bshow = Bshow.new(params[:bshow])

    respond_to do |format|
      if @bshow.save
        format.html { redirect_to @bshow, notice: 'Bshow was successfully created.' }
        format.json { render json: @bshow, status: :created, location: @bshow }
      else
        format.html { render action: "new" }
        format.json { render json: @bshow.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /bshows/1
  # PUT /bshows/1.json
  def update
    @bshow = Bshow.find(params[:id])

    respond_to do |format|
      if @bshow.update_attributes(params[:bshow])
        format.html { redirect_to @bshow, notice: 'Bshow was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @bshow.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bshows/1
  # DELETE /bshows/1.json
  def destroy
    @bshow = Bshow.find(params[:id])
    @bshow.destroy

    respond_to do |format|
      format.html { redirect_to bshows_url }
      format.json { head :no_content }
    end
  end
end
