# -*- encoding : utf-8 -*-
require 'rest_client'
require 'json'

class WeixinController < ApplicationController
  caches_action :post

  skip_before_filter :verify_authenticity_token
  before_filter :check_weixin_legality, :only => [:show, :create]
  before_filter :initialize 
  before_filter :set_city_by_lnglat
 
  def show
    render :text => params[:echostr]
  end

  def shop
    @page = 1
    @limit = 10
    @cid = nil

    if params[:page]
      @page = params[:page].to_i
    end
    if params[:cid]
      @cid = params[:cid].to_i
    end

    @shop = Shop.includes().find_by_url(params[:id])
    if @shop
      @discount = @shop.get_current_discount
      @comments = @shop.comments.order('updated_at DESC')
      @brand = @shop.brand
      @skus = @brand.skus.where("skus.level >= #{@brand.level}").where("skus.deleted=false or skus.deleted is null ").paginate(:page=>params[:page], :per_page=>10, :order=>'created_at DESC')
      @items = @skus.map{|sku| sku.wrap_item(@shop.id) }
      
 
      @first_page = "/weixin/shop?id=#{params[:id]}&#{@lbs_params}"
      @next_page = "/weixin/shop?id=#{params[:id]}&page=#{@page+1}&#{@lbs_params}"
    end

    respond_to do |format|
      format.html{
        render "shop", :layout => "weixin"
      } 
    end
  end


  def brand
    @page = 1
    @limit = 10

    if params[:page]
      @page = params[:page].to_i
    end
    @brand = Brand.find(params[:id])
    if @brand
      @skus = @brand.skus.paginate(:page=>@page, :per_page=>@limit, :order=>'created_at DESC')
      @objs = @skus
      @discount = @brand.get_last_discount
   
      @first_page = "/weixin/brand?id=#{params[:id]}&#{@lbs_params}"
      @next_page = "/weixin/brand?id=#{params[:id]}&page=#{@page+1}&#{@lbs_params}"
      
      get_brand_shops(@brand.id)
    end


    respond_to do |format|
      format.html{
        render "brand", :layout => "weixin"
      }
    end
  end

 
  def brands
    @limit = 20
    @page = 1
    cond = "1=1"
    if params[:limit]
      @limit = params[:limit].to_i
    end
    if params[:prefix]
      cond = "url LIKE '#{params[:prefix].downcase}%'"
      @query = params[:prefix]
    end

    if params[:page]
      @page = params[:page].to_i
    end

    @objs=Brand.where("#{cond}").where("level >= 4").order("updated_at desc").paginate(:page=>params[:page], :per_page=>@limit)
    @next_page = "/weixin/brands?page=#{@page+1}&#{@lbs_params}"

    respond_to do |format|
      format.html{
        render "brands", :layout => "weixin"
      }
    end
  end

  def games
    render "games", :layout => "weixin"
  end


  def matter
    @matter = Matter.find_by_id(params[:id])
    if @matter and @matter.brand_id 
      @brand = Brand.find_by_id @matter.brand_id
    end

    if @matter
      @brand_path =  "/weixin/brand?id=#{@matter.brand_id}"
    end
    respond_to do |format|
      format.html{
        if not @matter
          redirect_to "/weixin/matter?id=#{params[:id]}"
        else
          render "matter", :layout => "weixin"
        end
      }
    end
  end

 

  def post
    @post = Post.includes().find_by_id(params[:id])
    respond_to do |format|
      format.html{
        render "post", :layout => "weixin"
      }
    end
  end


  def dapei
    @dapei = Dapei.find_by_url(params[:id])
    respond_to do |format|
      format.html{
        render "dapei", :layout => "weixin"
      }
    end
  end

 
  def dapeis
    @page = 1
    if params[:page]
      @page = params[:page].to_i
    end
    @dapeis = Dapei.where(:category_id => "1001" ).where("level > 0").order("created_at desc").page(params[:page]).per(10)    
    @objs = @dapeis
    @limit = 10
    @next_page = "/weixin/dapeis?page=#{@page+1}&#{@lbs_params}"
    respond_to do |format|
      format.html{
        render "dapeis", :layout => "weixin"
      }
    end
  end


  
  def posts
    @page = 1
    if params[:page]
      @page = params[:page].to_i
    end
    @posts = Post.where( "category_id > 1" ).order("created_at desc").page(params[:page]).per(10)
    @objs = @posts
    @limit = 10
    @next_page = "/weixin/posts?page=#{@page+1}&#{@lbs_params}"
    respond_to do |format|
      format.html{
        render "posts", :layout => "weixin"
      }
    end
  end



  def discount
    @discount = Discount.includes().find_by_id(params[:id])
    @discounts=[]
    @inst = @discount.discountable
    @inst.discounts.order('created_at DESC').each do |d|
      if not d.deleted
        @discounts << d
      end
    end
    if @discount.discountable_type=="Shop"
      @inst_path =  "/weixin/shop?id=#{@inst.url}&#{@lbs_params}"
    elsif @discount.discountable_type=="Brand"
      @inst_path =  "/weixin/brand?id=#{@inst.id}&#{@lbs_params}"
    end
    respond_to do |format|
      format.html{
        render "discount", :layout => "weixin"
      }
    end
  end


  def help
      pre
      render "help", :layout => "weixin"
  end
  

  def test
      pre

      @q= ""
      if params[:q]
        @q =  params[:q]
      end
      if params[:shop]
        @index = "shop"
        res = RestClient.get "http://localhost:8080/shop/info/search.json", {:params => {:q => @q} }
        @res = JSON.parse(res)
        p @res
        if not @res["shops"] or @res["shops"].length == 0
           render "guide", :formats => :xml
        else
           render "shops", :formats => :xml
        end
      elsif params[:item]
        res = RestClient.get "http://localhost:8080/item/info/search.json", {:params => {:q => @q, :lng => params[:lng], :lat => params[:lat]} }
        @res = JSON.parse(res)
        render "items", :formats => :xml
      elsif params[:discount]
        res = RestClient.get "http://localhost:8080/discount/info/search.json", {:params => {:q => @q} }
        @res = JSON.parse(res)
        p @res
        render "discounts", :formats => :xml
      elsif params[:search]
        pre   
        render "search", :formats => :xml
      elsif params[:guide]
        render "guide", :formats => :xml
      elsif params[:help]
        render "help", :formats => :xml
      end
  end

  def format_link(index, lng, lat, q)
      domain = "http://www.shangjieba.com"
      if lng and lat
        ln = lng.gsub(".", "dot")
        la = lat.gsub(".", "dot")
      end
      "#{domain}/weixin/s/_#{index}_#{ln}_#{la}_#{q}.html"
  end

  def pre
      domain = "http://www.shangjieba.com"
 
      @objs = []
      url = format_link("discount", @lng, @lat, @q)
      @objs << {"title" => "查看附近优惠活动【实时】", "img"=>"#{domain}/assets/weixin_face.png", "url"=>"#{url}" }
      url = format_link("item", @lng, @lat, @q)
      @objs << {"title" => "查看附近漂亮宝贝【专柜同步】", "img"=>"#{domain}/assets/weixin_baobei.jpg", "url"=>"#{url}"  }
      url = format_link("shop", @lng, @lat, @q)
      @objs << {"title" => "查看附近精品服装店【...】", "img"=>"#{domain}/assets/weixin_dianpu.jpg", "url"=>"#{url}" }

      @pos_img = "#{domain}/assets/weixin_pos.png" 
      @help_txt = '''
1.点击下面的 + 然后发送位置, 查看周边新品和优惠 

2.发送 关键字 ,查看相关新品

3.发送 关键字+dp ,查看相关服装店

4.发送 关键字+yh ,查看相关优惠

5.发送 h , 查看帮助
'''
      @help =  {"title" => "使用帮助", "img"=>@pos_img, "url"=>"#{domain}/weixin/help","desc"=>"#{@help_txt}" } 
 end

  def parse_option
      if params[:option]
         ops = params[:option].split('_')
         #p "!!!", ops
         if ops.length >= 4
            params[:index] = ops[1]
            params[:lng] = ops[2].gsub("dot", ".")
            params[:lat] = ops[3].gsub("dot", ".") 
            if ops[4]
              params[:q] = ops[4]
            end
         end
         #p params
      end
  end

  def create
    if params[:xml][:MsgType] == "event"
       type =  params[:xml][:Event]
       if type == "subscribe"
         render "get_started", :formats => :xml
       end
    end
    if params[:xml][:MsgType] == "text"
       @q = ""
       @q = params[:xml][:Content].strip()
       pre
       #old action
       if @q == "Hello2BizUser"
         #render "get_started", :formats => :xml
         render "help", :formats => :xml
       elsif @q == "h"
         render "help", :formats => :xml
       else
         @index = "item"
         @page = 1
         @limit = 10
         if @q.index("dp")
           @index= "shop"
           @q = @q.gsub("dp", "")
         end
         if @q.index("yh")
           @index= "discount"
           @q = @q.gsub("yh", "")
         end
  
         params_dict =  {:index => @index, :q => @q, :limit=>@limit,  :page => @page, :from=>"weixin"} 
         res = RestClient.get "http://localhost:8080/#{@index}/info/search.json", { :params => params_dict }
         #p res
         @res = JSON.parse(res)
         key = "#{@index}s"  
         if not @res[key] or @res[key].length <= 0
           render "guide", :formats => :xml
         else
           render "#{key}", :formats => :xml
         end
         #render "search", :formats => :xml
       end
    end

    if params[:xml][:MsgType] == "location"
      @lat = params[:xml][:Location_X]
      @lng = params[:xml][:Location_Y]
      label =  params[:xml][:Label]
     
      pre 
      #res = RestClient.get "http://localhost:8080/shop/info/search.json", {:params => {:lng => lng, :lat => lat, :from=>"weixin"} } 
      #@res = JSON.parse(res)
      #render "shops", :formats => :xml
      render "search", :formats => :xml
    end
  end

  def homepage
     render "homepage", :layout =>false
  end

  def homepage2
     render "homepage2", :layout=>false
  end 

  def search
    parse_option
    @q = ""
    @index = "shop"
    @page = 1
    @limit = 12
    @sort = "hot"
    if params[:q]
      @q = params[:q]
    end
    if params[:page]
      @page = params[:page].to_i
    end
    if params[:index]
      @index = params[:index]
    end

    if @index == "discount"
      @sort = ""
    end

    params_dict =  {:index => @index, :q => @q, :sort => @sort, :limit=>@limit, :city_id => @city_id, :page => @page, :from=>"weixin"}
    geo=""
    if params[:lng] and params[:lat] and params[:lng] != "" and params[:lat] != ""
      params_dict = params_dict.merge({ :lng=>params[:lng], :lat=>params[:lat] })
      geo = "&lng=#{params[:lng]}&lat=#{params[:lat]}"
    end
   
    res = RestClient.get "http://www.shangjieba.com:8080/info/search.json", {:params => params_dict}
    @res = JSON.parse(res)
    @next_page = "/weixin/search?#{@lbs_params}&index=#{@index}&q=#{@q}&page=#{@page+1}#{geo}"  

    @objs = [] 
    if @index == "shop" 
      @objs = @res['shops'] if @res['shops']
      if @objs.length <= 3
        @shops=Shop.recommended(@city_id)
      end
      render "shops", :layout => "weixin"
    end

    if @index == "dapei"
      @objs = @res['dapeis'] if @res['dapeis']
      @dapeis = @objs.map{|obj| Dapei.find_by_url( obj['dapei_id'] )}
      @dapeis = Dapei.dup(@dapeis)
      render "dapeis", :layout => "weixin"
    end
    
    if @index == "item"
      @objs = @res['items'] if @res['items']
      if @objs.length <= 3
        @items = Item.recommended(@city_id)
      end
      render "items", :layout => "weixin"
    end
 
    if @index == "discount"
      @objs = @res['discounts'] if @res['discounts']
      if @objs.length <= 3
        @discounts = Discount.recommended(@city_id)
      end 
      render "discounts", :layout => "weixin"
    end  
  end

  def download
    ua = request.user_agent.downcase
    target = "http://leapcliff.com/materials/1381"
    if ua.index("ios") or ua.index("iphone") or ua.index("ipad")
        target = "https://itunes.apple.com/us/app/shang-jie-ba/id657031277?ls=1"
    end
    redirect_to target
  end


  def ad_download
    ua = request.user_agent.downcase
    target = "http://share.weiyun.com/f09d2e6cc70bef0259c4f26181e96618"
    if ua.index("ios") or ua.index("iphone") or ua.index("ipad")
        target = "https://itunes.apple.com/us/app/shang-jie-ba/id657031277?ls=1"
    end
    if ua.index("android")
        target = "http://share.weiyun.com/f09d2e6cc70bef0259c4f26181e96618"
    end
    redirect_to target
  end

  def android_download
    path = File.join('/data/www/shangjieba', 'public', 'shangjieba.apk')
    send_file path 
  end

  def app
    @appstore_path = "https://itunes.apple.com/us/app/shang-jie-ba/id657031277?ls=1&mt=8"
    @android_app = "http://fusion.qq.com/cgi-bin/qzapps/unified_jump?appid=10261569&from=wx&isTimeline=false&actionFlag=0&params=pname%3Dcom.shangjieba.client.android%26versioncode%3D14%26actionflag%3D0%26channelid%3D";
    #@android_app = "http://share.weiyun.com/148d2da8b7e4e1d59aeacc198e651065"
    render :layout => false
  end


  def sg_app
    @android_app = "http://fusion.qq.com/cgi-bin/qzapps/unified_jump?appid=10261569&from=wx&isTimeline=false&actionFlag=0&params=pname%3Dcom.shangjieba.client.android%26versioncode%3D14%26actionflag%3D0%26channelid%3D";
    @appstore_path = "https://itunes.apple.com/cn/app/you-pin-shan-gou-jing-xuan/id834282059?mt=8"
    render :layout => false
  end

  def ad_app
    @appstore_path = "https://itunes.apple.com/us/app/shang-jie-ba/id657031277?ls=1&mt=8"
    @android_app = "http://share.weiyun.com/f09d2e6cc70bef0259c4f26181e96618"
    render :layout => false
  end

  private

  def check_weixin_legality
    array = [Rails.configuration.weixin_token, params[:timestamp], params[:nonce]].sort
    render :text => "Forbidden", :status => 403 if params[:signature] != Digest::SHA1.hexdigest(array.join)
  end
  
  def initialize
     @get_started = "亲，欢迎关注上街吧。点击[+]然后发送[位置]就看看附近的漂亮衣服和实时优惠哦。发送h可查看具体使用说明。"
     @options = {"搭配"=>"dapei", "店铺"=>"shop", "宝贝"=>"item", "资讯"=>"discount" }
  end

  def get_brand_shops(brand_id)
    searcher = Searcher.new(@city_id, "shop", "", "near", 10, @page, nil, nil, @lng, @lat, brand_id )
    @shops = searcher.search()
    if @shops.length == 0
      searcher = Searcher.new(0, "shop", "", "near", 10, @page, nil, nil, @lng, @lat, brand_id )
      @shops = searcher.search()
    end
  end

  def set_city_by_lnglat
     $sphinx.ResetFilters
     if  params[:city_id]
       session[:city_id] =  params[:city_id]
     end
     if params[:lng] and params[:lat]
       session[:lng] = params[:lng]
       session[:lat] = params[:lat]
       @lng = params[:lng]
       @lat = params[:lat]
     end
     if not params[:city_id] and params[:lng] and params[:lat]
       @lng = params[:lng]
       @lat = params[:lat]
       lat = to_anchor( @lat.to_f )
       lng = to_anchor( @lng.to_f )
       $sphinx.SetGeoAnchor('lat_radians', 'long_radians', lat, lng)
       $sphinx.SetSortMode(Sphinx::Client::SPH_SORT_EXTENDED, '@geodist ASC, @relevance DESC')
       
       results =  $sphinx.Query("", "shop")
       if results and results['matches']
         results['matches'].each do |doc|
           @area = Area.city( doc['attrs']['city_id'] ).first
           @city = @area.city
           @city_id =  @area.city_id
           session[:city_id] = @city_id
           break
         end
       end
     end
     @lbs_params = "city_id=#{@city_id}&lng=#{@lng.to_s}&lat=#{@lat.to_s}"
  end
end
