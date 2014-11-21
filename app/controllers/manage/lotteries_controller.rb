# -*- encoding : utf-8 -*-
class Manage::LotteriesController < Manage::BaseController

  before_filter :set_param_side

  # GET /lotteries
  # GET /lotteries.json
  def index
    @lotteries = Lottery.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @lotteries }
    end
  end

  # GET /lotteries/1
  # GET /lotteries/1.json
  def show
    @lottery = Lottery.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @lottery }
    end
  end

  def current
    @lottery = Lottery.last

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @lottery }
    end
  end


  # GET /lotteries/new
  # GET /lotteries/new.json
  def new
    @lottery = Lottery.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @lottery }
    end
  end

  # GET /lotteries/1/edit
  def edit
    @lottery = Lottery.find(params[:id])
  end

  # POST /lotteries
  # POST /lotteries.json
  def create
    @lottery = Lottery.new(params[:lottery])

    respond_to do |format|
      if @lottery.save
        format.html { redirect_to [:manage, @lottery], notice: 'Lottery was successfully created.' }
        format.json { render json: @lottery, status: :created, location: @lottery }
      else
        format.html { render action: "new" }
        format.json { render json: @lottery.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /lotteries/1
  # PUT /lotteries/1.json
  def update
    @lottery = Lottery.find(params[:id])

    respond_to do |format|
      if @lottery.update_attributes(params[:lottery])
        format.html { redirect_to [:manage, @lottery], notice: 'Lottery was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @lottery.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /lotteries/1
  # DELETE /lotteries/1.json
  def destroy
    @lottery = Lottery.find(params[:id])
    @lottery.destroy

    respond_to do |format|
      format.html { redirect_to manage_lotteries_url }
      format.json { head :no_content }
    end
  end


  private
  def set_param_side
    params[:side] = 'manage/areas/sidebar'
  end

end
