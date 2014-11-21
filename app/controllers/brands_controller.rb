# -*- encoding : utf-8 -*-

def to_array(inst)
  if inst.is_a?(Array)
    return inst
  else
    return [inst.to_i]
  end
  []
end


class BrandsController < ApplicationController
  #caches_action  :show,  :if => Proc.new{|c|c.request.format.json?}
  caches_action  :index, :if => Proc.new{|c|p c.request.params[:limit].to_i >= 2000 }
  caches_action  :brands_recommended
  #caches_action :brand_skus, :brand_items, :brand_discounts, :if => Proc.new{|c|p c.request.params[:page].to_i == 1 }

  load_and_authorize_resource :except=>[:index, :brand_skus, :like_users, :brand_items, :brand_discounts, :brand_discounts_new, :brand_shops, :brand_lookbooks, :recommended_brands, :upload]
  before_filter :load_city, :load_brand, :only=>[:open_shop]

  skip_before_filter :verify_authenticity_token, :only => [:upload]
  
  #def add_existing_shop
  #  @brand=Brand.find(params[:id])
  #  @shop = Shop.find_by_url(params[:shop_id])
  #  @shop.brand_id=@brand.id
  #end

  def index
    @limit  =20
    if params[:limit]
      @limit = params[:limit].to_i
    end
     
    order = "url asc" 
    if params[:sort] == "sku"
        order = "skus_count DESC"
    elsif params[:sort] == "shop"
        order = "shops_count DESC"
    elsif params[:sort] == "name"
        order = "name ASC"
    elsif params[:sort] == "level"
        order = "level DESC"
    else
    end
 
    if params[:q] and params[:q] != ""
      searcher = Searcher.new(nil, "brand", params[:q], nil, 10, params[:page])
      @paged_brands = searcher.search()
      @count = searcher.get_count
    else   
      tcond = "1=1"
      if params[:brand_tags]
        bts = params[:brand_tags].split(",")
        bts.each do |tid|
          bt = BrandTag.find_by_id(tid)
          next unless bt
          tcond += " and brand_type = #{tid}"  if bt.type_id == 1
          tcond += " and brand_type_1 = #{tid}"  if bt.type_id == 2
          tcond += " and brand_type_2 = #{tid}"  if bt.type_id == 3
          tcond += " and brand_type_3 = #{tid}"  if bt.type_id == 4
        end
      end
      @count = Brand.where("level >= 4").where(tcond).length

      if params[:sort] == "hot"
         @paged_brands=Brand.where(tcond).where("level >= 4").order("updated_at desc").paginate(:page=>params[:page], :per_page=>@limit)
      else
         @paged_brands=Brand.where(tcond).where("level >= 4").order("name ASC").paginate(:page=>params[:page], :per_page=>@limit)
      end

    end

    respond_to do |format|
      format.html {@brands = Brand.order(order)}  # index.html.erb
      format.json { render_for_api :public, :json => @paged_brands, :meta => {:total =>@count } }
    end
  end

  def check
    level = 3
    @skip = true
    if params[:skip]
      @skip = false
    end
    level = params[:level] if params[:level]
    @brands = Brand.where("level >= #{level}").order("level desc")
  end

  def web_index
    @index = 'brand'
    @limit = 20
    cond = "1=1"
    if params[:limit]
      @limit = params[:limit].to_i
    end
    if params[:prefix]
      cond = "url LIKE '#{params[:prefix].downcase}%'"
      @query = params[:prefix]
    end

    if params[:sort] == "sku"
       @brands = Brand.order("skus_count DESC")
    elsif params[:sort] == "shop"
       @brands = Brand.order("shops_count DESC")
    elsif params[:sort] == "name"
       @brands = Brand.order("name ASC")
    else
       @brands = Brand.order("url asc")
    end
    @count = Brand.where("#{cond}").where("level >= 4").length
    @total_found = @count
    @paged_brands=Brand.where("#{cond}").where("level >= 4").order("name ASC").paginate(:page=>params[:page], :per_page=>@limit)
    #@top_yifu_brands = Brand.order("name asc").limit(12)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render_for_api :public, :json => @paged_brands, :meta => {:total =>@brands.length } }
    end
  end

  def admin_index
    order_by = "url asc"
    if params[:sort] == "sku"
       order_by = "skus_count DESC"
    elsif params[:sort] == "shop"
       order_by = "shops_count DESC"
    else
       order_by = "url asc"
    end
    @brands = Brand.order(order_by).page(params[:page]).per(5000)
    respond_to do |format|
      format.html # new.html.haml
      format.json {render :json => @shops}
    end
  end

  # GET /brands/1
  # GET /brands/1.json
  def show

    @brand = Brand.where(:id => params[:id]).first

    respond_to do |format|
      format.html # show.html.erb
      format.json { render_for_api :priv, :json => @brand, :meta => {:result=>"0" } }
    end
  end

  def web_show
    @page = "1"
    if params[:page]
      @page = params[:page]
    end
    @brand = Brand.includes().find(params[:id])

    cur_city = Area.city( @city_id ).first
    lng = cur_city.jindu if cur_city
    lat = cur_city.weidu if cur_city
    searcher = Searcher.new(@city_id, "shop", "", "near", 10, @page, nil, nil, lng, lat, @brand.id )
    @shops = searcher.search()
    @count = searcher.get_count()
    @other_count = 0
    if @count == 0
      searcher = Searcher.new(0, "shop", "", "near", 10, @page, nil, nil, @lng, @lat, @brand.id )
      @shops = searcher.search()
      @other_count =  searcher.get_count()
    end


    #searcher = Searcher.new(@city_id, "shop", "", "near", 10, @page, nil, nil, @lng, @lat, @brand.id )
    #@shops = searcher.search()
    #@count = searcher.get_count()
    #@shops = @brand.shops.where("shops.city_id=?", @city_id)
    @count = @shops.length

    @f3shops = @shops.first(4)
    if @count>4
      @lshops=@shops[4,@count-4]
    end  

    respond_to do |format|
      format.html # show.html.erb
      format.json { render_for_api :priv, :json => @brand, :meta => {:result=>"0" } }
    end
  end


  def brand_lookbooks
    @limit = 10
    @count = Sku.where('category_id = ?', 101).group(:brand_id).length
    @paged_lookbooks = Sku.where('category_id = ?', 101).group(:brand_id).order('created_at DESC').paginate(:page=>params[:page], :per_page=>@limit)    
     respond_to do |format|
      format.json { render_for_api :priv, :json => @paged_lookbooks, :meta => {:total =>@count } }
    end 
 end


  def brand_skus
    @brand = Brand.includes().find(params[:id])
    where = "1=1"
    @cid = nil
    if params[:cid]
      @cid = params[:cid].to_i
    end
    @count = @brand.get_skus_count(@cid)
    blevel = 4
    @skus = @brand.skus.where("level >= #{blevel} and deleted is null ").where("#{where}").paginate(:page=>params[:page], :per_page=>10, :order=>'created_at DESC')
    respond_to do |format|
      format.html # new.html.haml
      format.json {render_for_api :public, :json => @skus, :meta => {:result=>"0", :total =>@count.to_s }}
    end
  end

 
  def like_users
    @target = Brand.find_by_id( params[:id] )
    page = 1
    limit = 8
    page = params[:page].to_i if params[:page]
    limit = params[:limit].to_i if params[:limit]
    @users = Like.like_users( @target, params[:page], limit )

   if @dapei
      @like_users = @brand.likes.order('created_at DESC').paginate(:page=>params[:page], :per_page=>@limit).map(&:user)
    end
    respond_to do |format|
      format.json { render_for_api :public, :json=>@users, :meta=>{:result=>"0",  :total_count=> @target.likes_count.to_s } }
    end
  end


  def brand_items
    @brand = Brand.includes().find(params[:id])
    where = "1=1"
    @cid = nil
    if params[:cid]
      @cid = params[:cid].to_i
    end
    @count = @brand.get_skus_count(@cid)
    blevel = 4
    @skus = @brand.skus.where("level >= #{blevel} and deleted is null ").where("#{where}").paginate(:page=>params[:page], :per_page=>10, :order=>'created_at DESC')
    @items = @skus.map{|sku| sku.wrap_item}
    respond_to do |format|
      format.html # new.html.haml
      format.json {render_for_api :public, :json => @items, :meta => {:result=>"0", :total =>@count.to_s }}
    end
  end

  def brand_discounts
    #@brand = Brand.includes().find(params[:id])
    #@discounts=@brand.discounts.where("discounts.deleted is NULL")
    @count=0
    #@count=@discounts.length if @discounts
    #@paged_discounts = @brand.discounts.where("discounts.deleted is NULL").paginate(:page=>params[:page], :per_page=>10, :order=>'created_at DESC')
    @paged_discounts = []    

    respond_to do |format|
      format.html # new.html.haml
      format.json {render_for_api :public, :json => @paged_discounts, :meta => {:result=>"0", :total =>@count.to_s }}
    end
  end

 
  def brand_discounts_new
    @brand = Brand.includes().find(params[:id])
    @discounts=@brand.discounts
    @count=0
    @count=@discounts.length if @discounts
    @paged_discounts = @brand.discounts.where("discounts.deleted is NULL").paginate(:page=>params[:page], :per_page=>10, :order=>'created_at DESC')
 
    @notifications = []
    @paged_discounts.each do |bd|
      n = Notification.new
      n.notified_object_type = "Discount"
      n.notified_object = bd
      n.created_at = bd.created_at
      @notifications << n
    end

    respond_to do |format|
      format.json{render_for_api :common, :json=>@notifications, :api_cache => 30.minutes, :meta=>{:result=>"0"}}
    end
  end
 

  def brand_shops
    @page = "1"
    @brand = Brand.includes().find(params[:id])
    @shop_id = params[:shop_id] if params[:shop_id]
    @page = params[:page] if params[:page]
    @lng = params[:lng] if params[:lng]
    @lat = params[:lat] if params[:lat]
 
    #@shops = @brand.shops.where( :city_id => @city_id ).paginate(:page=>params[:page], :per_page=>10, :order=>'created_at DESC')
    @count = 0
    #@count = @shops.length if @shops

    searcher = Searcher.new(@city_id, "shop", "", "near", 10, @page, nil, nil, @lng, @lat, @brand.id )
    @shops = searcher.search()
    @count = searcher.get_count()
    @other_count = 0
    if @count == 0
      searcher = Searcher.new(0, "shop", "", "near", 10, @page, nil, nil, @lng, @lat, @brand.id )
      @shops = searcher.search()
      @other_count =  searcher.get_count()
    end

    respond_to do |format|
      format.html # new.html.haml
      format.json {render_for_api :public, :json => @shops, :meta => {:result=>"0", :total => @count.to_s, :all_count => @other_count.to_s }}
    end
  end

  def like_users
    @target= Brand.find_by_id(params[:id])
    @likes = @target.likes.page(params[:page]).per(8)
    @users = @likes.map(&:user)

    respond_to do |format|
      format.html { render :nothing=>true }
      format.json { render_for_api :light, :json => @users, :meta=>{:result=>"0"} }
    end
  end

  def manage_skus
    @brand = Brand.find(params[:id])
    @skus = @brand.skus.page(params[:page]).order('created_at DESC').per(50)
  end

  def manage_discounts
    @brand = Brand.find(params[:id])
    @discounts = @brand.discounts.page(params[:page]).order('created_at DESC').per(50)
            
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @discounts }
    end       
  end 

  def recommend_brand
    unless Recommend.find_by_recommended_type_and_recommended_id("Brand", params[:id] )
      @recommend = Recommend.new
      @recommend.recommended_type="Brand"
      @recommend.recommended_id=params[:id]
      @recommend.save
    end
    redirect_to :back
  end

  def recommended_brands
    @brands=Brand.recommended.limit(8)
    respond_to do |format|
      format.html { render :nothing=>true }
      format.json { render_for_api :public, :json => @brands, :meta=>{:result=>"0"} }
    end
  end


  # GET /brands/new
  # GET /brands/new.json
  def new
    @brand = Brand.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @brand }
    end
  end

  # GET /brands/1/edit
  def edit
    @brand = Brand.find(params[:id])
  end


  def open_shop
    @cities = Area.top_cities.order("pinyin asc")
    @shop = Shop.new
  end


  def shops
    @shops = @brand.shops.order("city_id asc")
  end

  def create_shop
    s = Shop.create( params[:shop].merge({:name => @brand.name}) )
    respond_to do |format|
      if s
        format.html { redirect_to :back } 
      else
        format.html { redirect_to :back }
      end
    end
  end

  # POST /brands
  # POST /brands.json
  def create
    if !params[:avatar_image]
      #add brand_photo, shop_photo here
      params[:brand] = params[:brand].merge(:avatar_id=>params[:photo]).merge(:shop_photo_id=>params[:shop_photo])
      @brand = Brand.new(params[:brand])
    else
      @avatar_id=Photo.build_avatar(current_user, params[:avatar_image], params[:avatar_image_type])
      @brand = Brand.new(params[:brand].merge(:avatar_id=>@avatar_id))
    end

    respond_to do |format|
      if @brand.save
        if params[:brand_image] and !Photo.correct_img_type?(params[:brand_image_type])
           format.json { render :json=>{:result=>"1", :error=>"wrong format of image format"} }
        else
          Photo.build_photo(current_user, params[:photos],params[:brand_image], params[:brand_image_type], @brand.id, "Brand")
        end

        format.html { redirect_to new_brand_sku_path @brand, notice: 'Brand was successfully created.' }
        format.json { render json: @brand, status: :created, location: @brand }
      else
        format.html { render action: "new" }
        format.json { render json: @brand.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /brands/1
  # PUT /brands/1.json
  def update
    @brand = Brand.find(params[:id])
    if(params[:photo])
      params[:brand]=params[:brand].merge(:avatar_id=>params[:photo] )
    end
    if(params[:shop_photo])
      params[:brand]=params[:brand].merge(:shop_photo_id=>params[:shop_photo] )
    end
    respond_to do |format|
      if @brand.update_attributes(params[:brand])
        if params[:brand_image] and !Photo.correct_img_type?(params[:brand_image_type])
           format.json { render :json=>{:result=>"1", :error=>"wrong format of image format"} }
        else
          Photo.build_photo(current_user, params[:photos],params[:brand_image], params[:brand_image_type], @brand.id, "Brand")
        end
        format.html { render action: "edit", notice: 'Brand was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @brand.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /brands/1
  # DELETE /brands/1.json
  def destroy
    @brand = Brand.find(params[:id])
    @brand.destroy

    respond_to do |format|
      format.html { redirect_to brands_url }
      format.json { head :no_content }
    end
  end

  def upload  
    require 'fileutils' #ruby老版本可尝试改为 require 'ftools'  
    
    dir = ""
    tmp = nil
    field = nil 
    
    brand_id = params[:brand_id]
    brand = Brand.find_by_id(brand_id)
    fn = Time.now.to_i.to_s 

    if params[:logo_file]
      tmp = params[:logo_file]
      dir = "logo"
      brand.wide_avatar_url = AppConfig[:remote_image_domain] +"/uploads/#{dir}/#{fn}.png"
    elsif params[:logo_white_file]
      dir = "logo_white"
      brand.white_avatar_url = AppConfig[:remote_image_domain] + "/uploads/#{dir}/#{fn}.png"
      tmp = params[:logo_white_file]
    elsif params[:logo_black_file]
      dir = "logo_black"
      brand.black_avatar_url = AppConfig[:remote_image_domain] + "/uploads/#{dir}/#{fn}.png"
      tmp = params[:logo_black_file]
    elsif params[:wide_banner_file]
      dir = "wide_banner"
      brand.wide_banner_url = AppConfig[:remote_image_domain] + "/uploads/#{dir}/#{fn}.png"
      tmp = params[:wide_banner_file]
    elsif params[:campaign_file]
      dir = "campaign"
      brand.campaign_img_url = AppConfig[:remote_image_domain] + "/uploads/#{dir}/#{fn}.png"
      tmp = params[:campaign_file]
    end

    file = File.join("/var/www/shangjieba/public/uploads/#{dir}", "#{fn}.png") 
    #FileUtils.cp tmp.path, file
    File.open(file, "wb") { |f| f.write( tmp[:file].read() ) }
    if brand
      brand.save
    end
    redirect_to :back
  end


  def brand_tags
    @types = {1 => "一般", 2 => "主营", 3 => "风格", 4 => "地域"}
    @brand_tag_group =[]
    [1, 2, 3, 4].each do |i|
       doc = {}
       doc['tid'] = i
       doc['name'] = @types[i]
       doc['tags'] = BrandTag.where( :type_id => i)
       @brand_tag_group << doc
    end
    @result = {}
    @result['status'] = "0"
    @result['brand_tags'] = @brand_tag_group
    respond_to do |format|
      format.json { render :json => @result }
    end
    
  end
end
