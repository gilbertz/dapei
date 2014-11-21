# -*- encoding : utf-8 -*-
class UserExtsController < ApplicationController
  layout false 

  # GET /user_exts
  # GET /user_exts.json
  def index
    @user_exts = UserExt.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @user_exts }
    end
  end

  # GET /user_exts/1
  # GET /user_exts/1.json
  def show
    @user_ext = UserExt.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user_ext }
    end
  end

  def cj
    unless params[:openid]
      respond_to do |format|
        format.html {
          render :text => "请向[上街吧]微信公众号，回复4321，进行抽奖"
        }
      end
    else
      email = params[:openid].downcase + "@shangjieba.com"
      user =  User.find_by_email( email )
      unless user
       respond_to do |format|
        format.html {
          render :text => "请先关注【上街吧】微信公众号，回复888，查看具体抽奖要求！"
        }
       end

      else
        @user_ext = UserExt.find_by_wx_gz_id( params[:openid] )
        @user_ext = UserExt.new unless @user_ext
        respond_to do |format|
          format.html { render :layout => false }
          format.json { render json: @user_ext }
        end
      end
    end
  end

  def cj2
      @user_ext = UserExt.find_by_wx_gz_id( params[:openid] )
      @user_ext = UserExt.new unless @user_ext
      respond_to do |format|
        format.html { render :layout => false }
        format.json { render json: @user_ext }
      end
  end

  # GET /user_exts/new
  # GET /user_exts/new.json
  def new
    @user_ext = UserExt.new

    respond_to do |format|
      format.html { render "cj", :layout => false }
      format.json { render json: @user_ext }
    end
  end

  # GET /user_exts/1/edit
  def edit
    @user_ext = UserExt.find(params[:id])
  end

  
  def reg
    email = params[:openid].downcase + "@shangjieba.com"
    user =  User.find_by_email( email )
    user = User.create(:name => "wx88_" , :email=>email, :password=>"weixin" ) unless user
    info = "用户号分配成功"
    info = "请向上街吧微信公众号，发送888，抽奖." unless params[:openid] 
    respond_to do |format|
        format.html {
          render :text => info
        }
    end
    
 
  end


  def new_create

    unless params[:token].blank?
      phone = params[:token].delete(" ")

      unless User.current_user.blank?

        ue = FiveOne.where(:user_id => User.current_user.id).order("id desc").first
        unless ue.blank?
          @t = "#{User.current_user.name} <br> 你的抽奖号是: <br> <span id='code'>#{ue.lucky_code}</span>"
        else
          incr_num = rand(5) + 1
          last_cj_num = FiveOne.last.try(:lucky_code).to_i
          cj_num = last_cj_num + incr_num
          ue = FiveOne.new(:user_id => User.current_user.id, :lucky_code => cj_num)
          ue.save

          @t = "#{User.current_user.name} <br> 你本次的抽奖号是: <br> <span id='code'>#{ue.lucky_code}</span>"
        end
      else
        @t = "请登陆后再领取抽奖号码"
      end

    end
  end

  def create_result
    render :text => params[:text]
  end

  # POST /user_exts
  # POST /user_exts.json
  def create
    email = params[:user_ext][:wx_gz_id].downcase + "@shangjieba.com"
    user =  User.find_by_email( email )
    #user = User.create(:name => params[:user_ext][:wx_id] , :email=>email, :password=>"weixin" ) unless user
    unless user
      respond_to do |format|
        format.html {
          render :text => "请先关注上街吧微信公众号，发送888, 查看抽奖详情。"
        }
      end
    else
      params[:user_ext][:user_id] = user.id

      incr_num = rand(5) + 1
      last_cj_num = UserExt.last.cj_num_1
      params[:user_ext][:cj_num_1] = last_cj_num + incr_num
      p "!!!", last_cj_num, incr_num   
 
      @user_ext = UserExt.new(params[:user_ext])

      respond_to do |format|
        if @user_ext.save
          format.html { redirect_to "/sjb/cj?openid=#{params[:user_ext][:wx_gz_id]}", notice: 'cj num was successfully deliver.' }
          format.json { render json: @user_ext, status: :created, location: @user_ext }
        else
          #format.html { redirect_to "/sjb/cj?openid=#{params[:user_ext][:wx_gz_id]}" }
          #format.html { render action: "new", :openid => "#{params[:user_ext][:wx_gz_id]}" }
          format.html { redirect_to "/sjb/cj?openid=#{params[:user_ext][:wx_gz_id]}", notice: '微信号不对！'}
          format.json { render json: @user_ext.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PUT /user_exts/1
  # PUT /user_exts/1.json
  def update
    @user_ext = UserExt.find(params[:id])

    respond_to do |format|
      if @user_ext.update_attributes(params[:user_ext])
        format.html { redirect_to "/sjb/cj?openid=#{params[:user_ext][:wx_gz_id]}", notice: 'User ext was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { redirect_to "/sjb/cj?openid=#{params[:user_ext][:wx_gz_id]}"  }
        format.json { render json: @user_ext.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /user_exts/1
  # DELETE /user_exts/1.json
  def destroy
    @user_ext = UserExt.find(params[:id])
    @user_ext.destroy

    respond_to do |format|
      format.html { redirect_to user_exts_url }
      format.json { head :no_content }
    end
  end
end
