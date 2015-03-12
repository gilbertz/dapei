class IbeaconsController < ApplicationController
  # GET /ibeacons
  # GET /ibeacons.json
  def index
    @ibeacons = Ibeacon.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @ibeacons }
    end
  end

  # GET /ibeacons/1
  # GET /ibeacons/1.json
  def show
    @ibeacon = Ibeacon.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @ibeacon }
    end
  end

  # GET /ibeacons/new
  # GET /ibeacons/new.json
  def new
    @ibeacon = Ibeacon.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @ibeacon }
    end
  end

  # GET /ibeacons/1/edit
  def edit
    @ibeacon = Ibeacon.find(params[:id])
  end

  # POST /ibeacons
  # POST /ibeacons.json
  def create
    @ibeacon = Ibeacon.new(params[:ibeacon])

    respond_to do |format|
      if @ibeacon.save
        format.html { redirect_to @ibeacon, notice: 'Ibeacon was successfully created.' }
        format.json { render json: @ibeacon, status: :created, location: @ibeacon }
      else
        format.html { render action: "new" }
        format.json { render json: @ibeacon.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /ibeacons/1
  # PUT /ibeacons/1.json
  def update
    @ibeacon = Ibeacon.find(params[:id])

    respond_to do |format|
      if @ibeacon.update_attributes(params[:ibeacon])
        format.html { redirect_to @ibeacon, notice: 'Ibeacon was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @ibeacon.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ibeacons/1
  # DELETE /ibeacons/1.json
  def destroy
    @ibeacon = Ibeacon.find(params[:id])
    @ibeacon.destroy

    respond_to do |format|
      format.html { redirect_to ibeacons_url }
      format.json { head :no_content }
    end
  end
end
