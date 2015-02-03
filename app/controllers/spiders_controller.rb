# -*- encoding : utf-8 -*-
#encoding:utf-8
class SpidersController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only=>[:create_sku]
  
  before_filter :load_brand, :only=>[:new, :edit]
  CRAWL_TYPE = {:spider=>0,
                :brand=>1
                }

  def initialize
    @categories = Category.where{(id >= 3)&(id < 15)}
  end


  # GET /spiders
  # GET /spiders.json
  def index
    @spiders = Spider.where(:stop => false)
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @spiders }
      format.rb {
        render "list", :layout => false
      }
    end
  end

  def schedule_index
    schedule_spiders(params[:templateid].to_i)

    respond_to do |format|
      format.rb {
        render "schedule_list", :layout => false
      }
    end
  end


  def schedule_spiders(templateid=nil)
    @spiders = Spider.where do
                 ([(brand_id.gt(1))&(is_template==false)]|(([template_id.eq(templateid)] unless templateid.nil?||templateid==0) || [])).reduce(:&)
               end
  end


  def crawl_index
    schedule_spiders(params[:templateid].to_i)

    respond_to do |format|
      format.rb {
        render "crawl_list", :layout => false
      }
    end
  end
  
  # GET /spiders/1
  # GET /spiders/1.json
  def show
    if params[:id]
      @spider = Spider.find(params[:id])
    end
    if params[:brand_id]
      @spider = Spider.find_by_brand_id(params[:brand_id])
    end
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @spider }
    end
  end

  def casperjs
    @brand_id = params[:brand_id]
    @spider = Spider.where( :brand_id => params[:brand_id] ).last
    @start_page = @spider.start_page
    @domain = "http://" + @start_page.split('/')[2] if @start_page and @start_page.split('/').length >= 3
    @ospider =  Spider.where( :brand_id => params[:brand_id] ).last

    if @spider.template_id  and  @spider.template_id > 0
      @spider = Spider.find_by_id(@spider.template_id)
    end
    respond_to do |format|
      format.js { render "show", :layout => false }
      format.rb { render "show", :layout => false }
    end
  end

  def crawl_common(id, crawl_type)
    return if id.nil? || id.empty?
    case crawl_type  
    when CRAWL_TYPE[:spider]
      @spider = Spider.find(id)
      @brand_id = @spider.brand_id
    when CRAWL_TYPE[:brand]
      @spider = Spider.where{brand_id==id}.order{created_at.desc}.first
      @spider_id = @spider.id
    end
   
  end

  def get_domain(start_page)
    domain = ""
    domain = "http://" + start_page.split('/')[2] if start_page.split('/').length >= 3
    domain
  end

  def get_domain_without_www(domain)    
    domain_without_www = ""
    domain_without_www = domain.split(".")[1..-1].join(".") if domain.split(".").length >= 3
    domain_without_www
  end

  def scheduler_common(id,crawl_type)
    crawl_common(id, crawl_type)
    @start_page = @spider.start_page
    #@domain = get_domain(@start_page)
    @ospider =  @spider
    if @spider.template_id  &&  @spider.template_id > 0
      @spider = Spider.find(@spider.template_id)
    end
 
  end

  def spider_scheduler
    @spider_id = params[:spider_id]
    scheduler_common(@spider_id, CRAWL_TYPE[:spider])
    respond_to do |format|
      format.rb { render "scheduler", :layout => false }
    end
  end

  def scheduler
    @brand_id = params[:brand_id]
    scheduler_common(@brand_id, CRAWL_TYPE[:brand]) 
    respond_to do |format|
      format.rb { render "scheduler", :layout => false }
    end
  end

  def new_scheduler
    @spider_id = params[:spider_id]
    scheduler_common(@spider_id, CRAWL_TYPE[:spider])
    respond_to do |format|
      format.rb { render "new_scheduler", :layout => false }
    end
  end

  def category_scheduler
    @spider = Spider.find params[:spider_id]
    respond_to do |format|
      format.rb { render "category_scheduler", :layout => false }
    end
  end

  def soldout    
    @origin_spider = Spider.where( :brand_id => params[:brand_id] ).includes(:brand).order{created_at.desc}.first
    @spider = @origin_spider.template_spider
    @links = @origin_spider.brand.skus.where{(buy_url!=nil)&((deleted==nil)|(deleted==false))}.map{|sku| [sku.buy_url, sku.docid]}
    respond_to do |format|
      format.rb { render "soldout", :layout => false }
    end
  end

  def spider_soldout    
    spider_id = params[:spider_id]
    @origin_spider = Spider.find(spider_id)
    start_page = start_page_all(@origin_spider)
    domain = get_domain(start_page)

    domain_without_www = get_domain_without_www(domain)
    
    @spider = @origin_spider.template_spider
    @links = @origin_spider.brand.skus.where{((buy_url!=nil)&(buy_url=~"%#{domain_without_www}%"))&((deleted==nil)|(deleted==false))}.map{|sku| [sku.buy_url, sku.docid]}
    respond_to do |format|
      format.rb { render "soldout", :layout => false }
    end
  end

  def spider_now_price    
    spider_id_p = params[:spider_id]
    @origin_spider = Spider.find(spider_id_p)
    start_page = start_page_all(@origin_spider)
    domain = get_domain(start_page)

    domain_without_www = get_domain_without_www(domain)
    
    @spider = @origin_spider.template_spider
    @links = Sku.where{(spider_id==spider_id_p)&(deleted==nil)}.map{|sku| [sku.buy_url, sku.docid]}
    respond_to do |format|
      format.rb { render "now_price", :layout => false }
    end
  end

  def start_page_all(spider)
    start_page = ""
    @categories.each do |cat|
      aa= ""
      aa = "_#{cat.id}" if cat.id > 3
      start_page += eval "spider.start_page#{aa}.to_s" 
    end
    spider_start_page = spider.start_page.to_s
    start_page += spider_start_page 
    start_page
  end

  def crawler_common(id,crawl_type)
    crawl_common(id, crawl_type)
    
    @start_page = start_page_all(@spider)
    #@domain = get_domain(@start_page)
    #@domain_without_www = get_domain_without_www(@domain)

    @ospider =  @spider
    spider_template_id = @spider.template_id
    if spider_template_id  and  spider_template_id > 0
      @spider = Spider.find(spider_template_id)
      case spider_template_id
      when 89 #tmall
        @origin_platform_name = "tmall"
      when 111 #net-a-porter
        @origin_platform_name = "net-a-porter"
      when 65 #银泰
        @origin_platform_name = "银泰"
      when 893 #zalando
        @origin_platform_name = "zalando"
      else
        @origin_platform_name = ""
      end
    end
 
  end

  def spider_crawler
    @spider_id = params[:spider_id]
    crawler_common(@spider_id, CRAWL_TYPE[:spider])
    respond_to do |format|
      format.rb { render "crawler", :layout => false }
    end

  end

  def crawler 
    @brand_id = params[:brand_id]
    crawler_common(@brand_id, CRAWL_TYPE[:brand])
    respond_to do |format|
      format.rb { render "crawler", :layout => false }
    end
  end

  def new_crawler
    @spider_id = params[:spider_id]
    crawler_common(@spider_id, CRAWL_TYPE[:spider])
    respond_to do |format|
      format.rb { render "new_crawler", :layout => false }
    end  
  end


  # GET /spiders/new
  # GET /spiders/new.json
  def new
    @spider = Spider.new
    @spider.brand_id = params[:brand_id] if params[:brand_id]
    @templates = Spider.where(:is_template => true )
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @spider }
    end
  end

  # GET /spiders/1/edit
  def edit
    @templates = Spider.where(:is_template => true )
    @spider = Spider.find(params[:id])
  end

  # POST /spiders
  # POST /spiders.json
  def create
    @spider = Spider.new(params[:spider])

    respond_to do |format|
      if @spider.save
        format.html { redirect_to @spider, notice: 'Spider was successfully created.' }
        format.json { render json: @spider, status: :created, location: @spider }
      else
        format.html { render action: "new" }
        format.json { render json: @spider.errors, status: :unprocessable_entity }
      end
    end
  end

  def create_sku
    response.header['Access-Control-Allow-Origin'] = '*'
    response.header['Content-Type'] = 'text/json'
    input = params.to_s.gsub(/\\\"/, "'") 
    keys = ["title", "brand", "productId", "styles", "currency", "comments",\
            "sizes", "color", "colorImageId", "sourceUrl", "sourceImgUrl", "domain"]
    doc = {}
    imgs =[]
    doc['type'] = (/'type':'(.*?)',/).match(input)[1]
    input.scan(/'imageId':{'value':'(.*?)',/).each {|m| imgs << m[0]}
    doc["imgs"] = imgs
   
    doc["price"] = ""
    doc["realPrice"] = "" 
    
    m1 = (/'price':{'value':(.*?),/).match(input)
    if m1
      doc["price"] = m1[1]
    end
    m2 = (/'realPrice':{'value':'(.*?)',/).match(input)
    if m2 
      doc["realPrice"] = m2[1]
    end

    keys.each do |key|
      m =input.match(/'#{key}':{'value':'(.*?)',/)
      if m
        doc[key] =m[1]
      else
        doc[key] = ""
      end
    end 
 
    doc["price"] = doc["currency"] + " " + doc["price"]
    doc["origin_price"] = doc["currency"] + " " + doc["realPrice"]
    doc["color_url"] = doc["colorImageId"]
 
    doc["tags"] = doc['type'] #+ "," + doc['styles']
    doc["url"] = doc["sourceUrl"]
    doc["pno"] = doc["productId"]
    
    sku_doc = Spider.new.parse(doc)
    
    if sku_doc[:brand_id] == 188 or sku_doc[:brand_id] == 153 or sku_doc[:brand_id] == 859 or not Sku.find_by_docid( sku_doc[:docid] ) or ( sku_doc[:pno] and sku_doc[:pno]!= "" and not Sku.find_by_pno( sku_doc[:pno] ) )
      sku = Sku.new( sku_doc )
       
      if sku.save
        sku.format_price
        sku_doc[:imgs].each do |img_url|
          p img_url
          begin
            photo_params={:image_url=>img_url }
            user = User.find_by_id(1)
            @photo = user.build_post(:photo, photo_params)
            @photo.target_id=sku.id
            @photo.target_type="Sku"
            @photo.save!
          rescue=>e
            p e.to_s
          end
        end 
      end
      render :text => '{"futurescorefacebook":"10","futurescoreqzone":"10","CondorJSONMsg":{"id":[3734667],"Status":"OK","Message":"exists!!!!"},"futurescoretwitter":"10","score":0,"futurescoreweibo":"10","futurescore":"10"}'.to_json, :content_type => 'application/json', :status => 200
    else
      sku = Sku.find_by_docid( sku_doc[:docid] ) 
      sku.update_attributes( sku_doc.merge(:s_price => sku_doc[:price]) )
      sku.format_price 
      if sku.photos.length <= 0
        sku_doc[:imgs].each do |img_url|
          p img_url
          begin
            photo_params={:image_url=>img_url }
            user = User.find_by_id(1)
            @photo = user.build_post(:photo, photo_params)
            @photo.target_id=sku.id
            @photo.target_type="Sku"
            @photo.save!
            sku.deleted = nil
            sku.save
          rescue=>e
            p e.to_s
          end
        end
      end

      render :text => '{"futurescorefacebook":"10","futurescoreqzone":"10","CondorJSONMsg":{"id":[3734667],"Status":"OK","Message":"Category UpdatedSuccessfully"},"futurescoretwitter":"10","score":0,"futurescoreweibo":"10","futurescore":"10"}'.to_json, :content_type => 'application/json', :status => 200
    end
   
  end

  # PUT /spiders/1
  # PUT /spiders/1.json
  def update
    @spider = Spider.find(params[:id])

    respond_to do |format|
      if @spider.update_attributes(params[:spider])
        format.html { redirect_to @spider, notice: 'Spider was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @spider.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /spiders/1
  # DELETE /spiders/1.json
  def destroy
    @spider = Spider.find(params[:id])
    @spider.destroy

    respond_to do |format|
      format.html { redirect_to spiders_url }
      format.json { head :no_content }
    end
  end

private
  def load_brand1
    brands = Brand.order("url asc")
    @brands = []
    brands.each do |b|
      if not b.spiders or b.spiders.length == 0
        @brands << b
      end
    end
  end

end
