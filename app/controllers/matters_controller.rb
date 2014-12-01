# -*- encoding : utf-8 -*-
#encoding: utf-8

class MattersController < ApplicationController

  
  skip_before_filter :verify_authenticity_token, :only => [:create, :new_matter]


  def get_dapeis
    matter = Matter.find_by_id( params[:id] )
    @dapeis = []
    @limit = 8
    @page = 1
    @limit = params[:limit].to_i if params[:limit]
    @page = params[:page].to_i if params[:page]
    if matter
      @dapeis = matter.get_dapeis(@limit, @page=1)
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
    if params[:no_category].to_i == 1
      cond = "is_cut = 1 and (category_id = 0 or category_id is null)"
    else
      unless params[:category_id].blank?

        rule_categories = Category.where("parent_id = ?", params[:category_id]).all.collect{|rc| rc.id }

        rule_categories_all = rule_categories.push(params[:category_id])

        cond = "is_cut = 1 and category_id in (#{rule_categories_all.join(',')})"
      else
        cond = "is_cut = 1 and category_id not in (123, 124, 125, 126, 127, 128, 129)"
      end
   end

   cat = Category.find_by_id( params[:category_id]  )
   user_cat = false
   if cat and cat.parent_id == 1140
      use_cat = true
   end

    if not params[:category_id] or use_cat
      @matters = Matter.where(cond).paginate(:order => "id desc", :page => params[:page], :per_page => 50)
    else
      @matters = Matter.category_search(params[:category_id], params[:page], 100)
    end

    #@rule_categories_for_select = RuleCategory.all_for_select

    @rule_categories_for_select = [["无", ""]] + Category.all.collect{|rc| [rc.name, rc.id] }
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
    matter = Matter.find(params[:id])
    matter.destroy

    redirect_to :back
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
