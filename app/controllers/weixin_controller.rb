# -*- encoding : utf-8 -*-
require 'rest_client'
require 'json'

class WeixinController < ApplicationController
  caches_action :post

  skip_before_filter :verify_authenticity_token
  before_filter :check_weixin_legality, :only => [:show, :create]
  before_filter :initialize 
 
  def show
    render :text => params[:echostr]
  end

  def brand
    @page = 1
    @limit = 10

    if params[:page]
      @page = params[:page].to_i
    end
    @brand = Brand.find(params[:id])
    if @brand
      @dapeis = @brand.get_dapeis(@limit, @page)
      @first_page = "/weixin/brand?id=#{params[:id]}"
      @next_page = "/weixin/brand?id=#{params[:id]}&page=#{@page+1}"
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

    #@objs=Brand.where("#{cond}").where("level >= 4").order("updated_at desc").paginate(:page=>params[:page], :per_page=>@limit)
    @brand_users = User.where( 'brand_id > 1' ).where( 'apply_type > 1' )
    @objs = @brand_users.map{|u|u.get_brand}

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
    if @matter
      if @matter.brand_id 
        @brand = Brand.find_by_id @matter.brand_id
        @brand_path =  "/weixin/brand?id=#{@matter.brand_id}"
      end
      @dapeis = @matter.get_dapeis
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
      domain = "http://www.dapeimishu.com"
 
      @objs = []
      @pos_img = "#{domain}/assets/weixin_pos.png" 
      @help_txt = '''

1.点击下面的 + 然后发送位置, 查看周边新品和优惠 

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
   
    res = RestClient.get "http://www.shangjieba.com:8080/info/search.json", {:params => params_dict}
    @res = JSON.parse(res)
    @next_page = "/weixin/search?#{@lbs_params}&index=#{@index}&q=#{@q}&page=#{@page+1}#{geo}"  

    @objs = [] 

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
     @get_started = "亲，欢迎关注搭配蜜书。发送h可查看具体使用说明。"
     @options = {"搭配"=>"dapei", "宝贝"=>"item" }
  end

end
