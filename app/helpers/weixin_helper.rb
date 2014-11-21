# -*- encoding : utf-8 -*-

module WeixinHelper

  def weixin_dapeis_path
    "/weixin/search?index=dapei&#{@lbs_params}"
  end

  def weixin_shops_path
    "/weixin/search?index=shop&#{@lbs_params}"
  end
 
  def weixin_shop_path(id)
    "/weixin/shop?id=#{id}&#{@lbs_params}"
  end

  def weixin_items_path
    "/weixin/search?index=item&#{@lbs_params}"
  end

  def weixin_item_path(id)
    "/weixin/item?id=#{id}&#{@lbs_params}"
  end

  def weixin_discounts_path
    "/weixin/search?index=discount&#{@lbs_params}"
  end

  def weixin_discount_path(id)
     "/weixin/discount?id=#{id}&#{@lbs_params}"
  end

  def weixin_brands_path(prefix=nil)
    option = ""
    option = "&prefix=#{prefix}" if prefix
    "/weixin/brands?#{@lbs_params}#{option}"
  end

  def weixin_brand_path(id)
    "/weixin/brand?id=#{id}&#{@lbs_params}"
  end


  def weixin_cities_path
    "/weixin/cities?#{@lbs_params}"
  end

  def weixin_games_path
    "http://www.wanhuir.com?fr=sj"
  end

  
  def weixin_posts_path
    "/weixin/posts?#{@lbs_params}"
  end


  def weixin_help_path
    "/weixin/help?#{@lbs_params}"
  end




##################################33
  def get_count
    if @res['total_found'].to_i > 10
       "10"
    else
       @res['total_found']
    end
  end

  def get_name(shop)
    if  shop['distance'] != "-1" and   shop['distance'] != "0米"
      shop['name']+ " " + shop['distance']  + "  (" + shop['dispose_count'] + "人瞄过)"
    else
      shop['name'] + "  (" + shop['dispose_count'] + "人瞄过)"
    end
  end

  def get_content(shop)
     shop['address'] + " " + shop['phone_number']
  end

  def get_img(shop, large=false)
     if large
       shop['img_sqr_medium']
     else
       shop['img_sqr_small']
     end
  end

  def get_url(shop)
     "http://www.shangjieba.com/weixin/shop?id=" + shop['shop_id']
     #"http://126.am/1CqdQ2"
  end


  def get_item_name(item)
    if item['title']
      if  item['distance'] != "-1" and item['distance'] != "0米"
        item['distance'] + " " + item['title'] +" " +item['shop_name'] + "  (" + item['dispose_count'] + "人瞄过)" 
      else
        item['title'] +" " +item['shop_name'] + "  (" + item['dispose_count'] + "人瞄过)" 
      end
    else
      item['shop_name']
    end
  end

  def get_item_url(item)
    #"http://www.shangjieba.com" + search_path("item", "", "", @q)
    #"http://www.shangjieba.com/#{item['shop_id']}/#{item['item_id']}.htm"
    
    "http://www.shangjieba.com/weixin/item?id=#{item['item_id']}"
  end

  def get_item_img(item,large=false)
      if large
         item['img_sqr_medium']
      else
         item['img_sqr_small']    
      end
  end

  def get_item_content(item)
      item['shop_address']+" "+item['updated_at']
  end


  
  def get_discount_name(item)
    if item['title']
      if  item['distance'] != "-1" and item['distance'] != "0米"
        item['distance'] + " " + item['title'] +" " +item['shop_name'] + "  (" + item['dispose_count'] + "人瞄过)"
      else
        item['title'] +" " +item['shop_name'] + "  (" + item['dispose_count'] + "人瞄过)"
      end
    else
      item['shop_name']
    end
  end

  def get_discount_url(item)
    "http://www.shangjieba.com/weixin/discount?id=#{item['discount_id']}"
  end

  def get_discount_img(item,large=false)
      if item['img_scaled_medium'] != ""
         item['img_scaled_medium']
      else
         item['img_wide_medium']
      end
  end

  def get_discount_content(item)
      item['description']
  end

  def show_distance(obj)
      if obj['distance'] and obj['distance'] != "0米" and obj['distance'] != "-1"
        obj['distance']
      else
      end
  end

end
