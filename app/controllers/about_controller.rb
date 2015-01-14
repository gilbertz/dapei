# -*- encoding : utf-8 -*-

class AboutController < ApplicationController
  skip_before_filter :verify_authenticity_token

  before_filter :set_title

  before_filter :get_help_content

  layout "about"

  def about_me
  end

  def shangou_option
    render :json=>{:show_ad => "0"} 
  end

  def app_banner
    datas = []
    dts = DapeiTag.where( :parent_id => 99 ).where( :is_hot => true ).order("created_at desc").limit(5)

    dts.each do |dt|  
      obj = {}
      obj["type"] = "dapei"
      obj["obj"] = dt
      obj["img_url"] = dt.get_img_url
      datas <<  obj
    end

    respond_to do |format|
      formpond_to do |format|
      format.json { render_for_api :public, :json => datas, :meta=>{:result=>"0"} }
    endt.json { render_for_api :public, :json => datas, :meta=>{:result=>"0"} }
    end
  end


  def app_banner_new
    datas = []
    dts = DapeiTag.where( :parent_id => 99 ).where( :is_hot => true ).order("created_at desc").limit(3)

    if true #current_user
      lotteries = Lottery.where(:on => true).order("created_at desc")
      lotteries.each do |lottery|
        ad = {}
        ad["type"] = "activity" 
        ad["title"] = lottery.title
        ad["img_url"] = lottery.img_url
        ad["click"] = lottery.link
        ad["wait"] = lottery.wait
        ad["obj"] = lottery
        datas << ad
      end
      if true
        dts.each do |dt|
          obj = {}
          obj["type"] = "dapei"
          obj["obj"] = dt
          obj["img_url"] = dt.get_img_url_old
          obj["theme_id"] = dt.id
          obj["wait"] = 1
          datas <<  obj
        end
      end
    end
    
    dapei_tags = []
    dapei_tags << {:id => 1, :name => '轻熟', :img_url => "http://qingchao1.qiniudn.com/uploads/dapei_tags/qingshu_big.png"}
    dapei_tags << {:id => 2, :name => '少淑', :img_url => "http://qingchao1.qiniudn.com/uploads/dapei_tags/shaoshu_big.png"}
    dapei_tags << {:id => 204, :name => '男人志', :img_url => "http://qingchao1.qiniudn.com/uploads/dapei_tags/nanshen_big.png"} 

    respond_to do |format|
      format.json { render_for_api :public, :json => datas, :meta=>{:result=>"0", :dapei_tags => dapei_tags, :dapei_tags_count => dapei_tags.length.to_s } }
    end
  end


  def dapei_banners
    datas = []
    #dts = DapeiTag.where( :parent_id => 99 ).where( :is_hot => true ).order("created_at desc").limit(3)
    dts = []    

    lotteries = Lottery.where(:on => true).order("created_at desc")
    lotteries.each do |lottery|
      ad = {}
      ad["type"] = "activity"
      ad["title"] = lottery.title
      ad["img_url"] = lottery.img_url + '?imageView2/1/w/640/h/320'
      ad["click"] = lottery.link
      ad["wait"] = lottery.wait
      ad["obj"] = lottery
      datas << ad
    end

    if true #current_user
      if true
        dts.each do |dt|
          obj = {}
          obj["type"] = "dapei"
          obj["obj"] = dt
          obj["img_url"] = dt.get_img_url
          obj["theme_id"] = dt.id
          obj["wait"] = 1
          datas <<  obj
        end
      end
    end

    respond_to do |format|
      format.json { render_for_api :public, :json => datas, :meta=>{:result=>"0" } }
    end
  end


  def dapei_tags
    tags = []
    
    @typesets = Typeset.all
    @typesets.each do |ts|
      next if ts.is_active == 0 
      next if ts.typeset_type.cell_types.blank?
      dict = {}
      dict['name'] = ts.name
      tgs = []
      ts.typeset_type.cell_types.each do |ct|
        sc = SetCell.where(:cell_type_id => ct.id, :typeset_id => ts.id).order("id desc").first
        if sc.present? and sc.image.present?
          tgs << {:id => sc.tag.id, :name => sc.tag.name, :img_url => sc.image } 
        end
      end
      dict['tag_num'] = tgs.length
      dict['tags'] = tgs
      
      tags << dict
    end

    @dt = DapeiTag.where( :parent_id => 99 ).where( :is_hot => true ).order("created_at desc").limit(2)
    @themes = @dt.map{ |d|d.to_json }  

    respond_to do |format|
       format.json {render :json => {:result =>'0', :themes=>@themes, :tags => tags } }
    end
  end


  def app_about
    render :layout=>"app_meta"
    #render :layout=>false
  end

  def app_business
    render :layout=>"app_meta"
  end

  def get_help_content
    # render :text=>"fdsf"
    @site_help =  SiteHelp.find_by_url_action(action_name)
    # return false
  end

  def index
    redirect_to "/about/about_me"
  end

  def feedback
    @feedback =Feedback.new
    render :layout => false
  end

  def download_app
    #redirect_to "https://itunes.apple.com/us/app/shang-jie-ba/id657031277?ls=1&mt=8"        
  end

  def create_feedback
    @feedback =Feedback.new(params[:feedback])
    if @feedback.save
      render :json=>{:result=>"0"}
    else
      render :json=>{:result=>"-1"}
    end
  end

  
  def version
    app_info = AppInfo.find_by_id(1)
    render :json=>{:result=>"0", :code => app_info.code, :version=>app_info.version, :ios_version => app_info.ios_version, :ios_app_url => app_info.ios_app_url,  :feature =>app_info.feature, :ios_id =>app_info.ios_id, :ios_url => app_info.ios_app_url,  :download_url => app_info.download_url}
  end

  def wanhuir_version
    app_info = AppInfo.find_by_id(2)
    render :json=> app_info
  end

  def shangou_version
    app_info = AppInfo.find_by_id(3)
    render :json=> app_info
  end

  def apps
    app = 
        {
            :back_url => "http://www.shangjieba.com",
            :click_url => "http://sc.hiapk.com/Download.aspx?aid=346&sc=1",
            :dev_name => "安卓市场",
            :desc => "安卓市场，最大最正牌的安卓软件下载平台。",
            :panel_small =>  "http://www.shangjieba.com/assets/market/anzhuo_72.png",
            :app_type =>  "tool",
            :name => "安卓市场",
            :panel_large =>  "http://www.shangjieba.com/assets/market/anzhuo_72.png",
            :icon_url => "http://www.shangjieba.com/assets/market/anzhuo_72.png",
            :banner_small => "http://www.shangjieba.com/assets/market/anzhuo_72.png",
            :banner_large =>  "http://www.shangjieba.com/assets/market/anzhuo_72.png",
            :show_cb_url => "",
            :banner_middle => "http://www.shangjieba.com/assets/market/anzhuo_72.png"
        }
    apps = []
    app1 = 
        {
            :back_url => "http://www.shangjieba.com",
            :click_url => "http://dl.sj.91.com/business/91soft/91assistant_Andphone181.apk",
            :dev_name => "91手机助手",
            :desc => "智能手机最佳伴侣，海量游戏应用随你淘",
            :panel_small =>  "http://wwww.shangjieba.com/assets/market/91_72.png",
            :app_type =>  "tool",
            :name => "91手机助手",
            :panel_large =>  "http://www.shangjieba.com/assets/market/91_72.png",
            :icon_url => "http://www.shangjieba.com/assets/market/91_72.png",
            :banner_small => "http://www.shangjieba.com/assets/market/91_72.png",
            :banner_large =>  "http://www.shangjieba.com/assets/market/91_72.png",
            :show_cb_url => "",
            :banner_middle => "http://www.shangjieba.com/assets/market/91_72.png"
        }
    #apps << app
    #apps << app1
    #is = ( rand(2) == 0 )
    is = false
    render :json => {:data => apps, :success => true, :show_flood => is}    
  
  end

  def contact
  end

  def report
    
  end

  def recruit
    
  end

  def cover
    if params[:q]
      @areas = Area.city_prefix(params[:q])
    end
    @areas ||= @recommended_cities
  end

  def fashion
    
  end

  def sitemaps
    
  end

  def mzsm
    render  layout: "application"
  end
  
  def brand_all
    if params[:q]
      @brand_all =  Brand.where("url LIKE :prefix", prefix: "#{params[:q].downcase}%")
    end
    @brand_all ||= @hot_rec_brands
  end
  
  def set_title
    @abouts = About.all
    # about_hash = {contact:"联系我们",about_me:"上街吧介绍",cover:"覆盖城市"} 
    # @title = about_hash[params[:action].to_sym]
    # unless params[:i]
      @abouts.each do |about|
        about.childs.each do |item|
          if item.action == action_name
            @title = item.name 
            @i = item.i #unless params[:i]
            break 
          end
        end
      end
    # end
  end
end
