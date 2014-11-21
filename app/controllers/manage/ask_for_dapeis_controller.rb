# -*- encoding : utf-8 -*-
class Manage::AskForDapeisController < Manage::BaseController
  skip_before_filter :verify_authenticity_token, :only => [:create]

  # GET /ask_for_dapeis
  # GET /ask_for_dapeis.json
  def index
    @page = 1
    @limit = 50 
    @page = params[:page].to_i if params[:page]
    @limit = params[:limit].to_i if params[:limit]
    cond = "1=1"
    filter = "level >= 0"
    if params[:user_id]
      user = User.find_by_url( params[:user_id] )
      cond = "user_id=#{user.id}"
    end

    order = 'created_at desc'
    if params[:order] and params[:order] == 'hot'
      order = 'answers_count desc'
    end

    if params[:n]
      @ask_for_dapeis = AskForDapei.where('answers_count is null').where(filter).order(order).page(@page).per(@limit)
      @count = AskForDapei.where('answers_count is null').where(filter).length
    else
      @ask_for_dapeis = AskForDapei.where('matter_id is not null').where(cond).order(order).page(@page).per(@limit)
      @top_requests = []
      if @page == 1 and not params[:user_id]
        @top_requests = AskForDapei.where('level >= 5').order('updated_at desc')
      end  
          
      @ask_for_dapeis = @top_requests + @ask_for_dapeis
      @count = AskForDapei.where(cond).length 

      @ask_for_dapeis = WillPaginate::Collection.create(@page, @limit, @count) do |pager|
        pager.replace @ask_for_dapeis
      end
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render_for_api :public, :json => @ask_for_dapeis, :meta=>{:result=>"0",  :total_count=>@count.to_s } }
    end
  end

  # GET /ask_for_dapeis/1
  # GET /ask_for_dapeis/1.json
  def show
    @ask_for_dapei = AskForDapei.find(params[:id])
    @ask_for_dapei.incr_dispose
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render_for_api :public, :json => @ask_for_dapei, :meta=>{:result=>"0"} } 
    end
  end

  # GET /ask_for_dapeis/new
  # GET /ask_for_dapeis/new.json
  def new
    @ask_for_dapei = AskForDapei.new
    @users = User.where("id > 22000").limit(200)
    @users_for_select = @users.collect{|c| [c.name, c.id] }
    @tags = Tag.where(:type_id => 2).map{|t|t.name }

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @ask_for_dapei }
    end
  end

  # GET /ask_for_dapeis/1/edit
  def edit
    @ask_for_dapei = AskForDapei.find(params[:id])
    
    @users = [@ask_for_dapei.user]
    @users += User.where("id > 21000").limit(200)
    @users_for_select = @users.collect{|c| [c.name, c.id] }

    @tags = Tag.where(:type_id => 2).map{|t|t.name }
  end

  # POST /ask_for_dapeis
  # POST /ask_for_dapeis.json
  def create
    if params[:matter_image]
      matter = Matter.build( params[:ask_for_dapei][:user_id], nil, nil, params[:matter_image])
      params[:ask_for_dapei][:matter_id] = matter.id 
      p matter
    end
 
    @ask_for_dapei = AskForDapei.new( params[:ask_for_dapei] )

    respond_to do |format|
      if @ask_for_dapei.save
        if params[:tags]
          @ask_for_dapei.tag_list.add( params[:tags] )
        end
       
        format.html { redirect_to @ask_for_dapei, notice: 'Ask for dapei was successfully created.' }
        format.json { render_for_api :public, :json => @ask_for_dapei, :meta=>{:result=>"0"} }
      else
        format.html { render action: "new" }
        format.json { render json: @ask_for_dapei.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /ask_for_dapeis/1
  # PUT /ask_for_dapeis/1.json
  def update
    @ask_for_dapei = AskForDapei.find(params[:id])

    if params[:tags]
      @ask_for_dapei.tag_list.add( params[:tags] )
    end 

    respond_to do |format|
      if @ask_for_dapei.update_attributes(params[:ask_for_dapei])
        format.html { redirect_to @ask_for_dapei, notice: 'Ask for dapei was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @ask_for_dapei.errors, status: :unprocessable_entity }
      end
    end
  end

  def undestroy
    @ask_for_dapei = AskForDapei.find(params[:id])
    @ask_for_dapei.level = 0
    @ask_for_dapei.save
  
    respond_to do |format|
      format.html { redirect_to :back }
      format.json { head :no_content }
    end
  end




  # DELETE /ask_for_dapeis/1
  # DELETE /ask_for_dapeis/1.json
  def destroy
    @ask_for_dapei = AskForDapei.find(params[:id])
    #@ask_for_dapei.destroy
    @ask_for_dapei.level = -1
    @ask_for_dapei.save

    respond_to do |format|
      format.html { redirect_to :back }
      format.json { head :no_content }
    end
  end
end
