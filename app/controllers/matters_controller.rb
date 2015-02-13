# -*- encoding : utf-8 -*-
#encoding: utf-8

class MattersController < ApplicationController

  
  skip_before_filter :verify_authenticity_token, :only => [:create, :new_matter]

  def show
    @matter = Matter.find( params[:id] )
    
    respond_to do |format|
      format.json { render_for_api :public, :json => @matter, :meta=>{:result=>"0"} }
    end
  end

  def get_dapeis
    matter = Matter.find_by_id( params[:id] )
    @dapeis = []
    @limit = 8
    @page = 1
    @limit = params[:limit].to_i if params[:limit]
    @page = params[:page].to_i if params[:page]
    if matter
      @dapeis = matter.get_dapeis(@page, @limit)
    end
    @count = @dapeis.length
    @dapeis = WillPaginate::Collection.create(@page, @limit, @count) do |pager|
      pager.replace @dapeis
    end
    respond_to do |format|
      format.html { render 'dapeis/index_all', :layout=>"new_app"}
      format.json { render_for_api :dapei_list, :json => @dapeis, :meta=>{:result=>"0", :total_count=>@count.to_s, :updated_count => "0"} }
    end
  end

  def view_show
    @matter = Matter.find_by_id( params[:id] )
    render :layout => false
  end

  def index
    cond = '1=1'
    @order = 'follow'
    if @su and @order == "follow"
      user_ids = []
      unless @su.is_shop
        @following_users = @su.following_by_type('User')
        user_ids = @following_users.map { |u| u.id }
      end
      user_ids << @su.id
      cond = {:user_id => user_ids}
    end
    @matters = Matter.where(cond).group(:docid).paginate(:page => params[:page], :per_page => 10)

    respond_to do |format|
      format.json { render_for_api :public, :json => @matters, :meta=>{:result=>"0"} }
    end
  end

  def edit
    @matter = Matter.find(params[:id])

    @matter_tags = MatterTag.all

    @rule_categories_select = RuleCategory.all.collect{|rc| [rc.category_name, rc.id] }

  end

  def update
    matter = Matter.find(params[:id])

    matter.update_attributes(params[:matter])
    
    unless params["matter_tags"].blank?
      matter.tags = params["matter_tags"].join(" ")
    end

    if matter.save
      render :text => "~~~~~~~~~~~~~~~~success~~~~~~~~~~~~~~~"
      return
    end
  end

  def destroy
    @matter = Matter.find(params[:id])
    #matter.destroy
    if @matter
      @matter.deleted = true
      @matter.save
    end
    respond_to do |format|
      format.html { redirect_to :back }
      format.json {render :json=>{:result=>"0"}}
    end
  end

  def recommend
    @matter = Matter.find(params[:id])
    @matter.recommend
    respond_to do |format|
      format.html { redirect_to :back }
      format.json {render :json=>{:result=>"0"}}
    end
  end

  def unrecommend
    @matter = Matter.find(params[:id])
    @matter.unrecommend
    respond_to do |format|
      format.html { redirect_to :back }
      format.json {render :json=>{:result=>"0"}}
    end
  end


  def new_matter
    @matter = Matter.new
    @matters = Matter.where( :user_id => current_user.id ).order('created_at desc').page(params[:page]).per(10)
    render 'new', :layout => "new_app"
  end

  def new

    if params[:pid].blank?
      render :text => "params pid is not exist"
      return
    end

    if params[:sid].blank?
      render :text => "params sid is not exist"
      return
    end

    photo = Photo.find_by_id(params[:pid])
    if Matter.find_by_sjb_photo_id(params[:pid])
       photo.is_send = 1
       photo.save
       render  :text => "Warn!~~~~~~~~~~~~~~~exists~~~~~~~~~~~~~~~~~~~"
    else
       @matter = Matter.new
       @matter.source_type = 1
       @matter.sjb_photo_id = params[:pid]
       @matter.sku_id = params[:sid]
       @matter.level = 5

       sku = Sku.find(params[:sid])

       sku_category_id = sku.category_id

       category_id = sku_category_id

       @matter.category_id = category_id

       puts @matter.inspect

       if @matter.save
         photo.is_send = 1
         photo.save
         render :text => "OK！~~~~~~~~~~~~~~~success~~~~~~~~~~~~~~~~~~~"
       else
         render :text => "Warn!~~~~~~~~~~~~~~~failed~~~~~~~~~~~~~~~~~~~"
       end
     end

  end

  def create
    #unless current_user.can_upload == "1" 
    if false
      render :json => {:error => "上传素材数量已经超过最大指，请申请达人。" }, :status => "failed"
    else
      if params[:matter_images]
        params[:matter_images].each do |m|
          m = Matter.build( current_user.id, nil, nil, m)
        end
        redirect_to :back
      else
        m = Matter.build( current_user.id, params[:matter_image], params[:matter_image_type])   
        if m
          respond_to do |format|
            format.html { render :nothing => true, :status => 201 }
            format.json { render json: m.to_jq_upload, status: :created } 
          end 
        end
      end
    end
  end

  def get_categories
    id = params[:id]
    @rule_categories = RuleCategory.find_all_by_father_id(id)
    render :layout => false
  end

  #上传素材
  def upload
    @categories = Category.where(:parent_id => 1140).all.collect{|c| [c.name, c.id] }
    @matter = Matter.new
    @matter_tags = MatterTag.all
  end

end
