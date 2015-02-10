# -*- encoding : utf-8 -*-

module ApplicationHelper

def photo_alt(item)
  #"#{item.category_name},#{item.shop_display_name},#{item.shop_street},#{item.shop_dist},#{item.shop_city}"
  if item.instance_of?(Item)
    "#{item.get_title} #{@city}#{item.shop_display_name}新品 #{item.brand_name}#{item.category_name}  #{@city}#{item.category_name}"
  elsif  item.instance_of?(Sku)
    "#{item.get_title} #{item.brand_name}#{item.category_name}"
  else
    ""
  end
end

def photo_title(item)
  #"#{item.get_title}"
  photo_alt(item)
end

def dapei_photo_alt(dp)
  #"#{item.category_name},#{item.shop_display_name},#{item.shop_street},#{item.shop_dist},#{item.shop_city}"
  if dp
    "搭配#{dp.title}"
  else
    "搭配"
  end
end

def dapei_photo_title(dp)
  if dp
    "搭配#{dp.title.to_s}"
  else
    "搭配"
  end
end

def brand_alt(brand)
   "#{@city}#{brand.name} #{@city}品牌"
end

def brand_title(brand)
   "#{@city}#{brand.name} #{@city}品牌"
end

def shop_alt(shop)
   "#{@city}#{shop.name}品牌图 #{@city}品牌"
end

def shop_title(shop)
   "#{@city}#{shop.name} #{@city}服装店"
end  


def dapei_page_seo(inst)
  meta_info = {}
  name = "搭配蜜书"
  name = inst.user.name if inst.user
  meta_info['title'] = "#{name}DIY作品, #{inst.title}搭配 - 搭配蜜书"
  meta_info['desc'] = "#{inst.title},#{inst.desc}-搭配蜜书"
  meta_info
end  


def page_seo(inst)
  info = ""
  if inst.instance_of?(Item)
     info = inst.show_name
     cname = ""
     cname = inst.category_name
     cells = inst.url.split('-')
     if cells.length > 1 and cells[-1].match /\d+/
       info += cells[-1]
     end
     brand_name = inst.brand_name
     if info.index(cname) == nil
        info += "," + brand_name + cname
     end
  end
  if inst.instance_of?(Discount)
    info = "#{inst.brand_name}#{inst.title}"
  end


  if inst.instance_of?(Brand)
    meta_info = {}
    brand_name = inst.get_name
    meta_info['title'] = "【#{brand_name}】#{@city}#{brand_name}新品|#{brand_name}分店|#{brand_name}活动优惠 - #{@city}搭配蜜书"
    meta_info['desc'] =  "搭配蜜书品牌汇,收集了最全的上海#{brand_name}新品、分店、折扣信息. #{inst.brand_intro}"
    meta_info['keywords'] =  "#{brand_name},#{@city}#{brand_name},#{brand_name}新品,#{brand_name}分店,#{brand_name}折扣"
  elsif inst.instance_of?(Sku)
    meta_info = {}
    brand_name = inst.brand_name
    meta_info['title'] = "#{inst.title}, #{@city}#{brand_name} - #{@city}搭配蜜书"
    meta_info['desc'] =  "#{inst.title}, 搭配蜜书品牌汇,收集了最全的上海#{brand_name}新品、分店、折扣信息"
    meta_info['keywords'] =  "#{inst.title}, #{inst.category_name}, #{brand_name},#{@city}#{brand_name}, #{brand_name}新品,#{brand_name}分店,#{brand_name}折扣"
  else
    shop_name = inst.shop_display_name
    localtion = "#{inst.shop_city}#{inst.shop_street}店"
    page_info = ""
    page_info = "第#{@page}页" if @page and  @page > 1

    title = "#{shop_name}#{inst.shop_city}品牌店，#{localtion}，#{page_info}"
    if info != ""
      title = "#{info}, #{shop_name}#{localtion}店，#{page_info}"   
    end

    desc = ""
    desc += "#{title}, 位于#{inst.shop_address}，进入#{inst.shop_name}页面查看更多的搭配，女装，女鞋，女包等单品照片和最新#{shop_name}打折优惠信息。"

    #case part  
    #when "title"
    #     "【图】#{title} - 搭配蜜书"
    #when "desc"
    #     desc       
    #when "keywords"
    #    "#{info},#{inst.name},#{inst.shop_name},#{inst.brand_name},#{inst.shop_city},#{inst.shop_street},图,搭配,价格,标价,女装,女鞋,女包,饰品,新品"
    #else
    #   "搭配蜜书"
    #end
    meta_info = {}
    meta_info['title'] = "【图】#{title} #{@city}搭配蜜书"
    meta_info['desc'] =  desc
    meta_info['keywords'] =  "#{info},#{inst.shop_city}#{inst.brand_name},#{inst.name},#{inst.shop_name},#{inst.brand_name},#{inst.shop_city},#{inst.shop_street},图,搭配,价格,标价,女装,女鞋,女包,饰品,新品"  
  end
  meta_info 
end


def user_page_seo(part, user, where="")
  name = "用户"
  name = user.display_name if user
  case part  
  when "title"
       "#{where}, #{name}个人主页-#{user.desc}-#{@city}搭配蜜书"
  when "desc" 
       "#{where}, #{name}的搭配蜜书是#{name}分享漂亮搭配和精彩逛街心得的社区,特色商铺,逛街足迹的个人主页,快来分享吧."
  when "keywords" 
       "#{name},个人主页,搭配,搭配蜜书,逛街,介绍,喜欢,评论,日志,好友,粉丝,女装"
  else
     "搭配蜜书" 
  end
end

def city_path(city_pinyin)
  "/#{city_pinyin}"
  #root_path.sub("www", city_pinyin)
end

def index_page_seo(results, index="")
  page_info = ""
  sort_info = ""
  index_info = "服装店"
  area_info = ""
  cat_info = "" 
  street_info = ""
  street_info = @street if @street
  brand_info = ""
  brand_info = @brand if @brand
  pic_info = ""
  city_info =""
  query_info = ""
  query_info = @query if @query
 
  page_info = "第#{@page}页" if @page and @page > 1
  
  query_info = street_info + query_info + brand_info
  
  sort_info = case @sort
               when 'hot' then "热门"      
               when "new" then "最新"
               when "near" then "最近"
               else ""
              end

  area_info = Area.find_by_dp_id(@dp_id).name if @dp_id and @dp_id != ""
  city_info = Area.city(@city_id)[0].city 

  cat_info = Category.find_by_id(@cid).name if @cid and @cid != ""
  index_info = case @index
               when 'discount' then "打折优惠资讯"      
               when 'item' then "服饰"
               when "shop" then "服装店"
               when "dapei" then "搭配"
               when "brand" then "品牌"
               else ""
              end
  index_info = "" if cat_info != ""
  #pic_info = "[多图]" if results.length > 0
  title_info = "#{pic_info}#{query_info}#{sort_info+index_info+cat_info}, #{city_info+area_info+street_info}时尚女装, #{page_info}"
  abc_info = ""
  abc_info = "#{params[:prefix]}开头" if params[:prefix] 
 
  if @cid and @cid != ""
    title_info = "#{query_info}#{cat_info}-#{sort_info}#{cat_info}单品,外贸#{cat_info},#{city_info}最齐全各式品牌#{cat_info}, #{page_info}"  
  elsif @index == "item"
    title_info = "#{query_info}新品-#{city_info}#{sort_info}单品"					
  elsif @index == "discount"
    title_info = "#{query_info}优惠活动-#{sort_info}#{city_info}品牌优惠折扣资讯发布"
  elsif @index == "shop"
    title_info = "#{query_info}服饰店-#{city_info}#{sort_info}品牌专卖店"
  elsif @index == "dapei"
   title_info = "#{query_info}#{sort_info}搭配-时尚女性穿衣搭配分享,在线搭配DIY"	
  elsif @index == "brand"
    title_info = "#{abc_info}品牌汇-最新最全的时尚服饰品牌大全，网罗各大卖场知名品牌"
  end
 
  desc_info = "搭配蜜书#{@city}站,时尚女性首选购物分享平台,方便快捷获取可靠有效的最新款时尚服装、包包、鞋子、配饰及其周边热门品牌、产品信息、优惠信息，轻松制作搭配,分享消费心得和美丽经验,尽享购物乐趣与实惠。" 
  desc_info += "搭配蜜书在#{city_info+area_info+street_info},为你找到了#{@total_found}个#{sort_info+index_info+cat_info}。" 
  keywords_info = "#{query_info},#{@city}#{brand_info},#{sort_info},#{@city}#{street_info},#{area_info},#{city_info},#{index_info},#{cat_info},搭配,图,价格,标价,#{@city}女装,#{@city}女包,#{@city}女鞋,#{@city}品牌"
  if @cid and @cid != ""
     keywords_info = ""
     keywords_info += "#{query_info}," if query_info != ""
     if @cid
       keyword_dict[@cid].each do |keyword|
         keywords_info += "#{city_info}#{keyword},品牌#{keyword},#{keyword}专卖店,最新款#{keyword},#{keyword}图片,外贸#{keyword},"
       end
     end
  elsif @index == "item"
     keywords_info = ""
     keywords_info += "#{query_info}," if query_info != ""
     keywords_info += "新品上架,最新款服装,最新款包包,最新款鞋子,最新款服饰,特卖新品,新品促销,新品导购"
  elsif @index == "discount"
     keywords_info = ""
     keywords_info += "#{query_info}," if query_info != ""
     keyword_dict["discount"].each do |keyword|
       keywords_info += "#{keyword}券,最新#{keyword}券,品牌#{keyword},服装#{keyword},包包#{keyword},鞋子#{keyword},服饰#{keyword},"
     end 
  elsif @index == "shop"
     keywords_info = ""
     keywords_info += "#{query_info}," if query_info != ""
     keywords_info += "服装专卖店,服装品牌店,包包专卖店,包包品牌店,鞋子专卖店,鞋子品牌店,服饰专卖店,服饰品牌店"
  elsif @index == "dapei"
     keywords_info = ""
     keywords_info += "#{query_info}," if query_info != ""
     keywords_info += "服装搭配,包包搭配,鞋子搭配,服饰搭配,搭配技巧,穿衣搭配,颜色搭配,换季搭配,明星搭配,淘宝"
  elsif @index == "brand"
     keywords_info = ""
     keywords_info += "#{query_info}," if query_info != ""
     keywords_info += "品牌汇,品牌大全,女装品牌,包包品牌,鞋子品牌,女鞋品牌,衣服品牌,配饰品牌,内衣品牌,裤装品牌,裙装品牌,上装品牌,男装品牌,国际大牌"
  end

  meta_info = {}
  meta_info['title'] =  "#{title_info}-搭配蜜书"
  meta_info['desc'] = "#{desc_info}"
  meta_info['keywords'] = "#{keywords_info}"
  meta_info

  #case part
  #when "title"
  #    "#{title_info}-搭配蜜书"
  #when "desc"
  #    "#{desc_info}"
  #when "keywords"
  #    "#{keywords_info}"
  #else
  #   "搭配蜜书"
  #end

end

def index_dict
  {"1" => "baobei", "2"=>"dapei", "3" => "yifu", "4"=>"xiezi", "5" => "baobao", "6"=>"peishi",\
   "7" => "nanzhuang", "8" =>"tongzhuang", "11" => "shangyi", "12" => "kuzi", "13" => "qunzi", "14" => "neiyi"}
end

def index_dict1
  {"1" => "baobei-shop", "2"=>"dapei-shop", "3" => "yifu-shop", "4"=>"xiezi-shop", "5" => "baobao-shop", "6"=>"peishi-shop",\
   "7" => "nanzhuang-shop", "8" =>"tongzhuang-shop", "11" => "shangyi-shop", "12" => "kuzi-shop", "13" => "qunzi-shop", "14" => "neiyi-shop"}
end

def index_dict2
  {"3" => "iyifu", "4" => "ixiezi", "5" => "ibaobao", "6" => "ipeishi", \
     "7" => "inanzhuang", "8" =>"itongzhuang", "11" => "ishangyi", "12" => "ikuzi", "13" => "iqunzi", "14" => "ineiyi"}
end


def keyword_dict
  {"1" => ["新品"], "2"=>["搭配"], "3" => ["服装", "女装"], "4"=>["鞋子", "女鞋"], "5" => ["包包", "女包"], "6"=>["饰品", "配饰"], \
   "discount" =>["优惠", "折扣"],"7" => ["男装"], "8" => ["童装"] , "11" => ["上衣", "上装"],"12" => ["裤装", "裤子"], "13" => ["裙装", "裙子"], "14" => ["内衣"],\
  }
end


def search_path(index="shop", sort="", dp_id="", q="", cid="", street="", mall="", brand="")
  q = q.sub('/','') if q
  index = "dapei" if index == ""
  sort = "" if sort== "hot" 
  cid_op = ""
  city_pinyin = ''
  city_pinyin = "" if index == "dapei"

  if cid != "" and index_dict.include?(cid)
     if index == "item" or index == "sku"
       index = index_dict[cid]
     elsif index == "shop"
       index = index_dict1[cid] 
     #elsif index == "sku"
     #  index = index_dict2[cid] 
     end 
  end 

  if  street != "" and brand != ""
     return "#{city_pinyin}/#{index}/_sb_#{q}_#{sort}_#{street}_#{brand}_a#{dp_id}.html"
  end
 
  if street != "" and dp_id == ""
    return "#{city_pinyin}/#{index}/_street_#{q}_#{sort}_#{street}.html"
  end

  if street != "" and dp_id != ""
    return "#{city_pinyin}/#{index}/_street_#{q}_#{sort}_#{street}_a#{dp_id}.html"
  end


  if mall != "" and dp_id == ""
    return "#{city_pinyin}/#{index}/_mall_#{q}_#{sort}_#{mall}.html"
  end

  if mall != "" and dp_id != ""
    return "#{city_pinyin}/#{index}/_mall_#{q}_#{sort}_#{mall}_a#{dp_id}.html"
  end

  if brand != "" and dp_id == ""
    return "#{city_pinyin}/#{index}/_brand_#{q}_#{sort}_#{brand}.html"
  end

  if brand != "" and dp_id != ""
    return "#{city_pinyin}/#{index}/_brand_#{q}_#{sort}_#{brand}_a#{dp_id}.html"
  end
  
  option = "index.html";
  if q != "" or sort != "" or dp_id != ""
    option = "_#{q}_#{sort}_a#{dp_id}.html"  
  end 

  return "#{city_pinyin}/#{index}/#{option}"

  #============= 
  
  option = ""
  option += "sort=#{sort}&" if sort != ""
  option = "" if index == "shop" and sort == "hot"
  option = "" if index == "item" and sort == "hot"

  #option += "dp_id=a#{dp_id}&" if dp_id != ""
  option += "q=#{q}&" if q != ""
  option += "street=#{street}&" if street != ""

  if option != ""
     option = "?#{option}"
  end


  if dp_id != ""
      if cid != ""
        return "/search/#{index}/#{cid}/a#{dp_id}#{option}"
      end
      return "/search/#{index}/a#{dp_id}#{option}"
  end
 
  if cid != "" and index == "item"
     return "/item/cat/#{cid}#{option}"
  end

  "/#{index}/info/search#{option}"
end


def li_class(sort="")
  if sort == @sort
      "Current"
  else
     ""
  end
end

def li_class_street(street="")
  if street == @street
      "active"
  else
      "" 
  end
end

def li_class_mall(mall="")
  if mall == @mall
      "active"
  else
      ""
  end
end

def li_class_brand(brand="")
  if brand == @brand
      "active"
  else
      ""
  end
end

def li_class_cat(cid="")
  if cid == @cid
      "active"
  else
      ""
  end
end

def cat_path(id)
 if @current_city
   city_pinyin = @current_city.pinyin
   "/#{city_pinyin}/#{index_dict[id]}/index.html"
 end
end

def new_shop_item_path(shop)
  "/#{shop.url}/item/new"
end

def shop_item_path(shop, item)
  #if shop and item
  #  "/#{shop.url}/#{item.url}.htm"
  #else
  #  "#"
  #end
  shop_item_path_orig(shop, item)
end

def shop_item_path_orig(shop, item)
  "/shops/#{shop.url}/items/#{item.url}"
end

def shop_path(shop)
  "/shops/#{shop.url}"
end

def shop_path_orig(shop)
  "/shops/#{shop.url}"
end

def manage_skus_path(brand)
  "/brand_admin/brands/#{brand.id}/manage_skus"
end

def manage_mall_discounts_path(mall)
   "/brand_admin/malls/#{mall.id}/manage_discounts"
end

def manage_brand_discounts_path(brand)
   "/brand_admin/brands/#{brand.id}/manage_discounts"
end

def new_brand_sku_multi_path(brand)
  "/brand_admin/brands/#{brand.id}/sku/new_multi"
end


def menu_class(cid)
  if @cid==cid
    "menu-hd select"
  else
    "menu-hd"
  end
end


def search_info
  @label = @dist_name.to_s + @street.to_s + @mall.to_s + @query.to_s
  info = "找到#{@total_found}个#{@label}" 
  info += "服装店" if @index == "shop"
  info += "宝贝" if @index == "item"
  info += "优惠" if @index == "discount"
  info += "搭配" if @index == "dapei"
  link_to info, search_path(@index, @sort, @dp_id, @query, @cid, @street)
end

def change_link
  name = "#{@label}服装店"
  name = "#{@label}宝贝" if  @index == "shop"
  index = "shop"
  index = "item" if @index == "shop"
  link_to name, search_path(index, @sort, @dp_id, @query, @cid, @street, @mall, @brand)
end

def recent_queries
  key = 'recent_queries'
  begin
    $redis.lrange(key, -100, -1).uniq
  rescue=>e
    []
  end
end

def mall_search_path(mall)
  search_path("shop", "", "", "", "", "", mall.name)
end

def next_item_path(shop, item)
  "/shops/#{shop.url}/items/#{item.url}/next" 
end

def prev_item_path(shop, item)
  "/shops/#{shop.url}/items/#{item.url}/prev"
end


def next_sku_path(brand, sku)
  "/brands/#{brand.url}/baobeis/#{sku.id}/next"
end

def prev_sku_path(brand, sku)
  "/brands/#{brand.url}/baobeis/#{sku.id}/prev"
end


def dapei_path(dapei)
  "/brand_admin/dapeis/#{dapei.id}"
end

def dapei_view_path(dapei)
  if dapei
    "/dapeis/view/#{dapei.url}"
  else
    ""
  end
end

def weixin_dapei_path(dapei)
  "/weixin/dapei?id=#{dapei.url}"
end

def dapei_list_path
  "/dapeis/index_all"
end

def edit_dapei_path(dapei)
  "/brand_admin/dapeis/#{dapei.id}/edit"
end

def shop_cat_path(shop, cid)
  if cid == nil or cid == ""
    shop_path(shop)
  else
    shop_path(shop) + "?cid=#{cid}"
  end
end

def brand_info_path(brand)
  "/brands/info/#{brand.id}"
end


def brand_baobei_path(brand, sku)
  "/brands/#{brand.url}/baobeis/#{sku.id}"
end

  def link_to_remote(*args, &block)
    link_to(*args.push(remote: true), &block)
  end

  def link_to_blank(body, url_options = {}, html_options = {})
    link_to(body, url_options, html_options.merge(target: "_blank"))
  end


def brands_web_show_path(brand)
  "/#{@current_city.pinyin}/brands/#{brand.id}"
end

def brands_web_index_path
  "/#{@current_city.pinyin}/brand/index.html"
end

def states
  states = (params[:q] && params[:q][:state_in]) || []
end

def state_success
  @state.eql?('success') ? true : false
end

def message_value
  state_success ? 'success' : 'error'
end

def result_value
  state_success ? 0 : 1
end

end
