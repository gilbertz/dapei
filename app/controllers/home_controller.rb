# -*- encoding : utf-8 -*-
class HomeController < ApplicationController
  before_filter :load_flinks
  #before_filter :load_area

  def index
    @shops = Shop.cache_recommend_shops_by_city_id(@city_id)
    
    @baobei = Sku.cache_recommend_sku_by_category_id(1)

    @shangzhuang=Sku.cache_recommend_sku_by_category_id(11)
    @kuzhuang=Sku.cache_recommend_sku_by_category_id(12)
    @qunzhuang=Sku.cache_recommend_sku_by_category_id(13)
    @neiyi = Sku.cache_recommend_sku_by_category_id(14)
    @xiezi=Sku.cache_recommend_sku_by_category_id(4)
    @baobao=Sku.cache_recommend_sku_by_category_id(5)
    @peishi=Sku.cache_recommend_sku_by_category_id(6)
    @nanzhuang=Sku.cache_recommend_sku_by_category_id(7)
    @tongzhuang =Sku.cache_recommend_sku_by_category_id(8)

    @lookbook = Sku.cache_recommended_lookbooks

    @dapei = Dapei.cache_recommended_all_by_category_id(1001)

    @sale_items = Searcher.new(nil, "item", "", "sale", 6).search()
    @brands = Brand.cache_brands_level_bigger_than(4)

    @wide3brands=@brands.first(3)
    @squre6brands=@brands.last(6)
    @normal9brands=@brands[3,9]
    @recommended_streets=Recommend.cache_recommended_streets_by_city_id(@city_id)
    @users=User.cache_recommended_by_city_id(@city_id)
    render :layout=>"home_2013"
  end

  def appmain
    @page = 1
    searcher = Searcher.new(nil, "dapei", nil,  "new", 50, @page)
    @dapeis = searcher.search()
    @dapeis = Dapei.dup(@dapeis)
    @dapeis = @dapeis.first(12)

    #@app_info = AppInfo.find(1)
    #@apk_url = @app_info.download_url

    render :template => "home/home", :layout => false

  end

  def citylist
    render :layout=>"home_2013"
  end

  def app
    render :layout=>"new_app"
  end

  def redirect
    if params[:url]
      redirect_to params[:url]
    end
  end

  def check_update
    sku_updated_at = Tagging.maximum('created_at').to_i 
    if Category.maximum('updated_at').to_i > Tagging.maximum('created_at').to_i 
      sku_updated_at = Category.maximum('updated_at').to_i
    end
    
    update =
        {
           :item_category =>  Category.maximum('updated_at').to_i,
           :dapei_tags => DapeiTag.maximum('updated_at').to_i,
           #:matter_category => Category.maximum('updated_at').to_i,
           :matter_category => Time.now.to_i,
           :brand_list => Brand.maximum('updated_at').to_i,
           :brand_tags => BrandTag.maximum('updated_at').to_i,
           :sku_tags => sku_updated_at,
           :show_wanhuir => 1,
           :use_yjs => 0,
           :share_change => 0.2,
           :all => 0
        }
    render :json => {:update => update, :success => true}
  end

  def check_update_new
    sku_updated_at = Tagging.maximum('created_at').to_i
    if Category.maximum('updated_at').to_i > Tagging.maximum('created_at').to_i
      sku_updated_at = Category.maximum('updated_at').to_i
    end

    update =
        {
           :item_category =>  Category.maximum('updated_at').to_i,
           :dapei_tags => DapeiTag.maximum('updated_at').to_i,
           #:matter_category => Category.maximum('updated_at').to_i,
           :matter_category => Category.maximum('updated_at').to_i,
           :brand_list => Brand.maximum('updated_at').to_i,
           :brand_tags => BrandTag.maximum('updated_at').to_i,
           :sku_tags => sku_updated_at,
           :show_wanhuir => 1,
           :use_yjs => 0,
           :share_change => 0.01,
           :all => 0
        }
    render :json => {:update => update, :success => true}
  end


end
