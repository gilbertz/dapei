# -*- encoding : utf-8 -*-

def to_array(inst)
  if inst.is_a?(Array)
    return inst
  elsif inst.is_a?(Integer)
    return [inst.to_i]
  end
  []
end


class Searcher
  attr_accessor :query
  attr_accessor :cit_id
  attr_accessor :index
  attr_accessor :lng
  attr_accessor :lat
  attr_accessor :radius
  attr_accessor :limit
  attr_accessor :page
  attr_accessor :cid
  attr_accessor :sort
  attr_accessor :shop_id
  attr_accessor :sphinx
  attr_accessor :bg


  def initialize(city_id, index, query=nil, sort=nil, limit=10, page= "1", cid=nil, shop_id=nil, lng=nil, lat=nil, brand_id=nil, sku_id=nil)
    @cit_id = city_id.to_i
    @query = query.gsub("(null)", "") if query
    @index = index
    @page = page
    if not page
      @page = 1
    end

    @cid = cid
    @sort = sort
    @shop_id = shop_id
    @lng = lng
    @lat = lat
    @brand_id = brand_id
    @sku_id = sku_id

    @level = 4
    @radius = 5000000 
    @limit = limit.to_i
    @offset = (@page.to_i - 1) * @limit.to_i
    @use_lnglat = false
    @mhit = 5000
    @count = 0
    @reranking = true
    @rgb = nil

    @bg = []
    @sg = []

    if @lng != nil and @lat != nil
      @use_lnglat = true
    end

    if @shop_id != nil or @brand_id != nil or @sku_id != nil or @index == "dapei_item_info" or  @index == "make" or @index == "dapei" or @index == "brand" or @index == "user" 
      @reranking = false
    end

    if @index == "matter"
     @sphinx = $sphinx_ii
     if @cid
       cat = Category.find_by_id(@cid)
       @parent_id = cat.parent_id
     end
     
     #for sub category search
     if @cid and Category.is_sub(@cid)
       if @parent_id != 9 and @parent_id != 10
         cname = Category.find_by_id(@cid).name
         @query = "#{@query} #{cname}"
         @cid = nil
       end
     end
    else
      @sphinx = $sphinx_i
    end
    if @index == "item"
       @index = "sku"
    end

    init
  end

  def set_color1(color)
    @rgb = color
    rgb = @rgb[1..6].to_i(16)
    r = ( rgb >> 16) % 256
    g = ( rgb >> 8 ) % 256
    b = rgb % 256
    range  = 50 
    @sphinx.SetFilterRange('r1', r-range, r+range)
    @sphinx.SetFilterRange('g1', g-range, g+range)
    @sphinx.SetFilterRange('b1', b-range, b+range) 
  end

  
  def set_color(color)
    @rgb = color
    if @rgb.length == 7
      rgb = @rgb[1..6].to_i(16)
    else
      rgb = @rgb.to_i(16)
    end
    r = ( rgb >> 16) % 256
    g = ( rgb >> 8 ) % 256
    b = rgb % 256
    @color_filter = true
  
    #expr = "-1*( ABS(r1-#{r}) + ABS( g1-#{g} ) + ABS( b1-#{b} ) ) * ( ABS(r2-#{r}) + ABS( g2-#{g} ) + ABS( b2-#{b} ) ) + (created_time - 1134028003)/45000"
    expr = "-1*( ABS(r1-#{r}) + ABS( g1-#{g} ) + ABS( b1-#{b} ) ) * ( ABS(r2-#{r}) + ABS( g2-#{g} ) + ABS( b2-#{b} ) )"
    @sphinx.SetSortMode(Sphinx::Client::SPH_SORT_EXPR, expr) 

 end


  def set_brand(brand_id)
    @sphinx.SetFilter('brand_id', [brand_id.to_i])
  end

  def set_user_id(uid)
    @sphinx.SetFilter('user_id', [uid.to_i])
  end

  def set_price(low_price, high_price)
    if high_price == "" or high_price == nil
      high_price = 10000000
    end
    @sphinx.SetFilterRange('refer_price', low_price.to_i, high_price.to_i)
  end

  def set_level(level)
    @sphinx.SetFilterRange('level', level.to_i, 11)
  end

  def remove_level(level)
    @sphinx.SetFilter('level', [level.to_i], true)
  end

  def set_sub_category_id(cid)
    @sphinx.SetFilter('sub_category_id', [cid.to_i])
  end

  def to_anchor f
    f/180.0*Math::PI 
  end

  def from_anchor f
    f*180.0/Math::PI
  end

  def format_distance(dist)
     if dist < 1000
        "#{dist.to_i}m"
     elsif dist < 10000
        "#{(dist/1000).round(1)}km"
     else
        "#{(dist/1000).to_i}km"
     end
  end

  def get_count
    @count
  end

  def total_entries
    @count
  end

  def total_pages
    (@count / @limit).floor
  end

  def current_page
    @page
  end

  def get_sphinx_result
      if @index == "item" and @sort != "near" and  @sku_id == nil
        @sphinx.SetGroupBy('sku_id', Sphinx::Client::SPH_GROUPBY_ATTR, '@expr desc')
      end

       q = "#{query_expand(@query)}"
       q = q.force_encoding("ASCII-8BIT")
       @keyword = q
      
       if @reranking    
          @sphinx.SetLimits(0, 1000)
       end
       
       results = @sphinx.Query(q, "#{@index};#{@index}_delta") 
       post

       @count = results["total_found"] if results
       results = reranking(results) if @reranking
       results['matches'] =  results['matches'][@offset, @limit] if @reranking
       results
  end

  def reranking(results)
    brand_names = {}
    streets = {}
    cids = {}
    if results['matches']
      idx = 1
      results['matches'].each do |r|
        idx += 1
        brand = r['attrs']['brand_name']
        street = r['attrs']['street']
        from = r['attrs']['source']
        cid = r['attrs']['category_id']
        price = r['attrs']['refer_price']

        if @index == "matter"
          price_level = 800
          if cid == 4 or cid == 5
            price_level = 2000
          end 
          if price.to_i > price_level
            r['attrs']['@expr'] -= 2000
          end
        end

        if @index == 'shop'
          if @keyword != "" and r['attrs']['street'].index(@keyword) or r['attrs']['brand_name'].index(@keyword)
            if r['attrs']['@expr']
               r['attrs']['@expr'] += 200000
            end
          end

          if brand_names.include?(brand)
            if r['attrs']['@expr']
               r['attrs']['@expr'] -= 3000*brand_names[brand]*brand_names[brand]
            end
            brand_names[brand] += 1
          else
            brand_names[brand] = 1
          end
        end

      end
      results['matches'] = results['matches'].sort{|a,b| b["attrs"]["@expr"]<=>a["attrs"]["@expr"] }
    end
    results
  end

  def query_expand_dict
    {"mecity" => "me city", "onon"=>"on on", "宝姿" =>"宝姿ports", "dfuse" => "d fuse", "enid"=>"eni:d", "百丽" => "百丽belle", "tods"=>"tod s", "衣索" => "衣索espresso"}
  end

  def query_expand(q)
    if q and q != ""
      q  = q.downcase
      query_expand_dict.each do |k, v|    
        if q.index(k)
          q = q.gsub(k, v)
        end
      end
    else
      q  = "" 
    end
    q
  end
  
 
  def search()
    results = get_sphinx_result
    post

    hits = []
    @geo = {}
    @total_found = 0

    if results and results['matches']
       @total_found = results['total_found']
       results['matches'].each do |doc|
         hits << doc['id']
         if doc['attrs']['@geodist']
           if @index == "discount" or @index == "brand" or @index == "user"
             @geo[doc['id']] = format_distance(doc['attrs']['@geodist'])
           else
             @geo[doc['attrs']['url']] = format_distance(doc['attrs']['@geodist'])
           end
         end
       end
    end 
   
    if results and results['total_found']
      @results = WillPaginate::Collection.create(@page,  @limit, results['total_found'].to_i > @mhit? @mhit : results['total_found'] ) do |pager|
        if @index == "comment"
          indexed_result = Shop.find_all_by_id(hits).index_by(&:id)
        else
          indexed_result = @index.capitalize.constantize.find_all_by_id(hits).index_by(&:id)
        end
        result = indexed_result.values_at(*hits)
        pager.replace(result)
      end
    

      if ['shop', 'item', 'discount'].include?(@index)
        @results.each do |inst|
          if inst and @index == "discount" and inst.id
            inst.distance = @geo[inst.id]
          elsif inst and inst.url
            inst.distance = @geo[inst.url]
          end
          if inst and not inst.distance 
            inst.distance = "-1"
          end
        end
      end
    end
    @results
  end

  def setFilter
    post
    @sphinx.SetLimits(@offset, @limit, @mhit)
 
    if @use_lnglat and @lng and @lat 
      lat = to_anchor( @lat.to_f )
      lng = to_anchor( @lng.to_f )
      @sphinx.SetGeoAnchor('lat_radians', 'long_radians', lat, lng);
      if @index == "item" or @index == "shop"
        @sphinx.SetFilterFloatRange('@geodist', 0.0, @radius);
      end
      @sort = 'near' if @sort == "" or @sort == nil
    end   
 
    if @index  == "item" 
      @sphinx.SetFilterRange('level', @level, 10)
    end
    
    if (@index == "item" or @index == "matter") and @cid and @cid != nil and @cid != 0
      if @cid.is_a?(Integer) and (@cid.to_i > 1000)
        if @parent_id == 9 or @parent_id == 10
          @sphinx.SetFilter('sub_category_id', to_array(@cid) )
        else
          @sphinx.SetFilter('matter_category_id', to_array(@cid) )
        end
      elsif @cid.to_i == 100 and User.current_user
        #for self matters
        @sphinx.SetFilter('matter_category_id', to_array(@cid) )
        @sphinx.SetFilter('user_id', [User.current_user.id])
      else 
        @sphinx.SetFilter('category_id', to_array(@cid) )
      end
    end

    if @index == "item" and @shop_id != nil
      @sphinx.SetFilter('shop_id', [@shop_id.to_i])
      @sphinx.SetFilterRange('ilevel', 3, 10)
    end

    if @brand_id != nil
      @sphinx.SetFilter('brand_id', [@brand_id.to_i])
    end

    if not @cit_id.blank? and @cit_id > 0 and @shop_id == nil and @sku_id == nil and @index  != "matter" and @index != "brand" and @index != "user"
      @sphinx.SetFilter('city_id', [@cit_id.to_i])
    end

    if @index == "item" and @sku_id != nil
      @sphinx.SetFilter('sku_id', to_array(@sku_id) )
      #@sphinx.SetGroupBy('sku_id', Sphinx::Client::SPH_GROUPBY_ATTR, '@expr desc')
    end

    if @index == "discount"
      today =  -1.days.since(Date.today)
      @sphinx.SetFilterRange('end_date', today.to_datetime.to_i, 180.days.since(today).to_datetime.to_i)
    end

    if @index == "matter"
      @sphinx.SetFilter('cut', [1])
    end

    if @index == "dapei"
       @sphinx.SetFilterRange('level', 2,  10)
    end

    #if @index == "item" and @sort != "near" and  @sku_id == nil 
    #  @sphinx.SetGroupBy('sku_id', Sphinx::Client::SPH_GROUPBY_ATTR, '@expr desc')
    #end

  end
  
 
  def geoSearchAgain(q, radius)
    if not @radius
      @radius = radius  
      setFilter 
      return @sphinx.Query(q, "#{@index};#{@index}_delta")       
    end

  end

  def index_dict
     {"baobei"=>"1", "dapei"=>"2", "yifu" =>"3", "xiezi"=>"4", "baobao"=>"5", "peishi"=>"6", "nanzhuang" => "7", \
      "shangyi" => "11", "kuzi" => "12", "qunzi" => "13", "neiyi" =>"14" }
  end

 
  def init
     post
     @sphinx.SetSortMode(Sphinx::Client::SPH_MATCH_ALL)
     setFilter

     if ( @sort == "" ) and @use_lnglat == false
       @sort = "hot"
     end

     if @index == "matter"
       @sort = "hot"
     end
    
     if @index == "brand" or  @index == "user"
       @sort = "new"
     end
 
     if @sort == "hot"
         expr = "level*2 + ln(items_count+1)*0.3 + ln(comments_count*5+likes_count*3+4*dispose_count+1) + 0.2*(updated_time - 1134028003)/45000 + 0.01*(created_time - 1134028003)/45000"
         if @index == "item" or @index == "sku"
             expr = "level*0.05 + 1.0*ln(comments_count*30+likes_count*5+dispose_count*10+1) + 0.2*(created_time - 1134028003)/45000"  
         end
         if @index == "discount"
             expr = "level*1 + 1.0*ln(comments_count*30+likes_count*5+dispose_count*20+1) + 0.5*(created_time - 1134028003)/45000"
         end

         if @index == "matter"
             #expr = "level*3 + blevel * 1 + 1.0*ln(comments_count*30+likes_count*5+dispose_count*1+1) + 0.2*(created_time - 1134028003)/45000 + 0.1*(sku_created_time - 1134028003)/45000 "  
             expr = "(created_time - 1134028003)/45000"
         end

         if @use_lnglat
             expr = expr + " - 5*ln(@geodist)"
         end
         
         @sphinx.SetSortMode(Sphinx::Client::SPH_SORT_EXPR, expr)
     end 

     if @sort == "sale" and ( @index == "item" or @index == "sku")
         #expr = "level*1 + 0.01 * ( 100 - off_percent )  + 0.1*ln(comments_count*5+likes_count*3+4*dispose_count) + 1.0*(created_time - 1134028003)/45000" 
         expr = "0.1 * ( 100 - off_percent ) + (created_time - 1134028003)/45000"
         @sphinx.SetFilterRange('off_percent', 5,  99)
         @sphinx.SetSortMode(Sphinx::Client::SPH_SORT_EXPR, expr)
     end
     
     if @sort == "new"
         expr = "(created_time - 1134028003)/45000 + 0.2*(updated_time - 1134028003)/45000"
         if @index == "shop"
            expr = "ln(items_count+1)*0.5 +0.4*(updated_time - 1134028003)/45000 + 0.1*(created_time - 1134028003)/45000"
         end
         if @use_lnglat
             expr = expr + "-50*@geodist"
         end
         @sphinx.SetSortMode(Sphinx::Client::SPH_SORT_EXPR, expr)
     end

     if @sort == "near" and @use_lnglat
         @sphinx.SetSortMode(Sphinx::Client::SPH_SORT_EXTENDED, '@geodist ASC, @relevance DESC')
     end
   
   end


   def getStreetGroup
     @sphinx.SetGroupBy('street', Sphinx::Client::SPH_GROUPBY_ATTR, '@count desc')
     @sphinx.SetLimits(@offset, 10000)
 
     q = "#{@query}"
     q = q.force_encoding("ASCII-8BIT")
     results = @sphinx.Query(q, "#{@index};#{@index}_delta")
     post 

     @sg = []
     n = 0
     if results and results['matches']
       results['matches'].each do |doc|
         if n > @limit.to_i
           break
         end
         if doc['attrs']['street'] != ""
           s = {}
           s['street'] = doc['attrs']['street'].force_encoding('UTF-8')
           s['count']  = doc['attrs']['@count'].to_s
           @sg << s
           n += 1
         end
       end
     end
  end


  def getCategoryGroup
     @sphinx.SetGroupBy('category_id', Sphinx::Client::SPH_GROUPBY_ATTR, '@count desc')
     @sphinx.SetLimits(@offset, 10000)

     setFilter

     q = "#{@q}"
     q = q.force_encoding("ASCII-8BIT")
     results = @sphinx.Query(q, "#{@index};#{@index}_delta")
     post

     @cg = []
     n = 0
     if results and results['matches']
       results['matches'].each do |doc|
         if doc['attrs']['street'] != ""
           s = {}
           s['cid'] = doc['attrs']['category_id']
           s['count'] = doc['attrs']['@count'].to_s
           @cg << s
         end
       end
     end
   end

 
   def getBrandGroup
     @sphinx.SetGroupBy('brand_id', Sphinx::Client::SPH_GROUPBY_ATTR, '@count desc')
     @sphinx.SetLimits(@offset, 10000)
     #@sphinx.SetFilterRange('level', @level, 10)

     @bg = []      
     q = "#{@query}".force_encoding("ASCII-8BIT")
     results = @sphinx.Query(q, "#{@index};#{@index}_delta")
     #p results

     n = 0
     if results and results['matches']
       results['matches'].each do |doc|
         #if n > @limit.to_i
         #  break
         #end
         if doc['attrs']['brand_id'] != ""
           s = {}
           s['brand_id'] = doc['attrs']['brand_id']
           s['count']  = doc['attrs']['@count'].to_s
           @bg << s
           n += 1
         end
       end
     end
     @bg
  end
 
  def get_bg
     @bg
  end  

  def get_sg
     @sg
  end

  def get_cg
     @cg
  end

  def post
     @sphinx.ResetFilters()
     @sphinx.ResetGroupBy()
  end


end
