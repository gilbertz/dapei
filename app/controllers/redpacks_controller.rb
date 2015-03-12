class RedpacksController < ApplicationController
  # GET /redpacks
  # GET /redpacks.json
  def index
    @redpacks = Redpack.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @redpacks }
    end
  end

  # GET /redpacks/1
  # GET /redpacks/1.json
  def show
    @redpack = Redpack.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @redpack }
    end
  end

  # GET /redpacks/new
  # GET /redpacks/new.json
  def new
    @redpack = Redpack.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @redpack }
    end
  end

  # GET /redpacks/1/edit
  def edit
    @redpack = Redpack.find(params[:id])
  end

  # POST /redpacks
  # POST /redpacks.json
  def create
    @redpack = Redpack.new(params[:redpack])

    respond_to do |format|
      if @redpack.save
        format.html { redirect_to @redpack, notice: 'Redpack was successfully created.' }
        format.json { render json: @redpack, status: :created, location: @redpack }
      else
        format.html { render action: "new" }
        format.json { render json: @redpack.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /redpacks/1
  # PUT /redpacks/1.json
  def update
    @redpack = Redpack.find(params[:id])

    respond_to do |format|
      if @redpack.update_attributes(params[:redpack])
        format.html { redirect_to @redpack, notice: 'Redpack was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @redpack.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /redpacks/1
  # DELETE /redpacks/1.json
  def destroy
    @redpack = Redpack.find(params[:id])
    @redpack.destroy

    respond_to do |format|
      format.html { redirect_to redpacks_url }
      format.json { head :no_content }
    end
  end
end
