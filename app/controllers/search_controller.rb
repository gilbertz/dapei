# -*- encoding : utf-8 -*-

class SearchController < ApplicationController
  before_filter :parse_option, :if => Proc.new{|c| not c.request.format.json?}

  def log_query
    if @q != "" and not @use_lnglat
      key = 'recent_queries'
      #$redis.del key
      $redis.lpush(key, @q)
      if @brand != ""
         $redis.lpush(key, @brand)
      end
      if ($redis.llen key).to_i > 200
         $redis.del key
      end
      #p $redis.lrange(key, 0, -1)
    end
  end

  def debug_log(info)
    @debug_info << "<p>" + info + "</p>" if @debug and Rails.env == "development"
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

  def get_sphinx_result(q)
      pkey = "s_#{@city_id}_#{@index}_#{q}_#{@sort}_#{@offset}_#{@limit}_#{@cid}_#{@tag_id}_#{@category_id}_#{@lng}_#{@lat}_#{@low_price}_#{@high_price}"
      gkey = "g_#{@city_id}_#{@index}_#{q}_#{@sort}_#{@offset}_#{@limit}_#{@cid}_#{@tag_id}_#{@category_id}_#{@lng}_#{@lat}_#{@low_price}_#{@high_price}"

      results = Rails.cache.fetch pkey, :expires_in => 10.minutes do
         q = query_expand(q)
         q = q.force_encoding("ASCII-8BIT")
         @keyword = q
         
         if @reranking
           if @index == "shop"
             $sphinx.SetLimits(0, 1000)
           elsif @index == "sku"
             $sphinx.SetLimits(0, 2000)
           else 
             $sphinx.SetLimits(0, 500) 
           end
         else
           $sphinx.SetLimits(@offset, @limit)
         end  
        
         results = $sphinx.Query(q, "#{@index};#{@index}_delta") 
         results = reranking(results) if @reranking
         results
      end       
      start = @offset.to_i
      limit = @limit.to_i
      
      if results and results['matches']
        results['matches'] =  results['matches'][start, limit]
      end

      if request.format != "json"
          getBrandGroup
          getStreetGroup
      elsif @index == "sku"
          @groups = Rails.cache.fetch gkey, :expires_in => 10.minutes do  
             getSkuGroup
          end  
      end
 
      results
  end

  def priority_score( priority )
     if 5 <= priority.to_i and priority.to_i < 8
       return 1 + priority.to_f / 10
     elsif priority.to_i  < 4
       return 1 - (5 - priority.to_i)/10
     else
       return 1
     end
  end


  def buy_domain(buy_url)
    if buy_url
      buy_url.gsub("http://", "").split("/")[0]
    else
      ""
    end
  end


  def price_range(price)
    if price.to_i > 1000
      return '1000,'
    elsif price.to_i > 500
      return '500,1000'
    elsif price.to_i > 100
      return '100,500'
    else
      return '0,100' 
    end 
  end


  def reranking(results)
    brand_names = {}
    streets = {}
    cids = {} 
    rids = []

    @brand_type_dict = {}
    @source_dict = {}
    @price_dict = {}
    @color_dict = {}
 
    if @index == "sku" and @q != ""
      rids = Sku.showing(100).map{|s|s.id} 
    end
 
    if results and results['matches']
      i = 0
      results['matches'].each do |r|
        i += 1
        break if not r['attrs']['@expr']

        brand = r['attrs']['brand_id']
        street = r['attrs']['street']
        from = r['attrs']['source']
        cid = r['attrs']['category_id'] if @index == "sku"
        price = r['attrs']['refer_price']      
 
        debug_log(r.to_s)  
        debug_log("docid=" + r['id'].to_s)
        debug_log("before rerank expr=" + r['attrs']['@expr'].to_s)
        debug_log("level factor:" + (r['attrs']['level']).to_s )
        debug_log("social factor:" + Math.log( r['attrs']['comments_count']*5 + r['attrs']['likes_count']*3 + r['attrs']['dispose_count'] + 1 ).to_s )
        debug_log("brand factor:"  + priority_score( r['attrs']['priority'] ).to_s )
        debug_log("time factor:" + ( 1*( r['attrs']['updated_time'] - 1134028003)/45000 ).to_s )  
  
        if r['attrs']['priority']
          r['attrs']['@expr'] += 15*priority_score( r['attrs']['priority'] )
          debug_log("++ priority_score=" + ( 15*priority_score( r['attrs']['priority'] ) ).to_s)
          if  r['attrs']['priority'] < 5
            r['attrs']['@expr'] -= 200* (5 - r['attrs']['priority'])
          end
        end
       
        #p r
        if @keyword != "" and  @index == 'shop' and ( r['attrs']['street'].index(@keyword) or r['attrs']['brand_name'].index(@keyword) )
           if r['attrs']['@expr']
               r['attrs']['@expr'] += 300000
           end
        end

        if @keyword != "" and  @index == 'sku'
           if r['attrs']['@expr']
               if  r['attrs']['head'] == @keyword
                 r['attrs']['@expr'] += 300000
               elsif r['attrs']['head'].index(@keyword)
                 r['attrs']['@expr'] += 100000
               elsif r['attrs']['synonym'].split(' ').include?(@keyword)
                 r['attrs']['@expr'] += 200000
               end
           end
        end

        if @index == 'sku'
           if r['attrs']['source'] != "homepage"
             r['attrs']['@expr'] -= 1000000
           end
           if rids.include?(r['id'])
             r['attrs']['@expr'] += 500000
             r['attrs']['@expr'] -= i * 2000
           end

           price_level = 800
           price_level = 2000 if cid == 4 or cid == 5
           if price > price_level
             r['attrs']['@expr'] -= 10000
           end
 
           if r['attrs']['brand_type'] and r['attrs']['brand_type'] != ""
             t = r['attrs']['brand_type'].to_i
             @brand_type_dict[t] = @brand_type_dict[t].to_i + 1 if t > 0
           end
           if r['attrs']['buy_url'] and  r['attrs']['buy_url'] != ""
             domain = buy_domain( r['attrs']['buy_url'] )
             @source_dict[domain] = @source_dict[domain].to_i + 1 
           end
           if r['attrs']['price'] and r['attrs']['price'] != ""
             pr = price_range( r['attrs']['price'] )
             @price_dict[pr] = @price_dict[pr].to_i + 1
           end
        end   


        if brand_names.include?(brand)
           if r['attrs']['@expr']
             debug_log("brand dup:#{brand} -= "  + (10000*brand_names[brand]*brand_names[brand]).to_s  )
             r['attrs']['@expr'] -= 10000*brand_names[brand]*brand_names[brand]
           end
           brand_names[brand] += 1
        else
           brand_names[brand] = 1
        end

        if cids.include?(cid)
           if r['attrs']['@expr']
             debug_log("cid dup:#{brand} -= "  + (10*cids[cid]).to_s  )
             r['attrs']['@expr'] -= 10*cids[cid]
           end
           cids[cid] += 1
        else
           cids[cid] = 1
        end

        if not @use_lnglat and street and streets.include?(street) 
           if r['attrs']['@expr']
             debug_log("street dup:#{street} -= " + (100*streets[street]*streets[street]).to_s )
             r['attrs']['@expr'] -= 100*streets[street]*streets[street]
           end
           streets[street] += 1
        else
           streets[street] = 1
        end
        debug_log("after rerank expr=" + r['attrs']['@expr'].to_s)
      end
      results['matches'] = results['matches'].sort{|a,b| b["attrs"]["@expr"]<=>a["attrs"]["@expr"] }
     
    end
    results
  end

  def query_expand_dict
    {"mecity" => "me city", "onon"=>"on on", "宝姿" =>"宝姿ports", "dfuse" => "d fuse", "enid"=>"eni:d", "百丽" => "百丽belle", "tods"=>"tod s", "衣索" => "衣索espresso"}
  end

  def query_expand(q)
    begin
      q  = q.downcase
      query_expand_dict.each do |k, v|    
       if q.index(k)
         q = q.gsub(k, v)
       end
      end
    rescue => e
    end
    q
  end
 
  def search_dapei
      $sphinx1.ResetFilters()
      $sphinx1.SetLimits(@offset, @limit)
      attr = "created_time"
      $sphinx1.SetSortMode(Sphinx::Client::SPH_SORT_ATTR_DESC, attr)
      $sphinx1.SetFilterRange("level", 1, 10)
      results = $sphinx1.Query("#{@q}".force_encoding("ASCII-8BIT"), "#{@index};#{@index}_delta")
  end


  def get_updated_count
    if current_user
      key = "sku_viewed_at_#{current_user.id}"
      if params[:uid]
        key = "sku_viewed_at_#{params[:uid]}" 
      end
      if $redis.get(key)
        max_id = $redis.get(key).to_i
      else
        max_id = 0
      end
      
      rs = Recommend.joins("INNER JOIN skus ON recommends.recommended_id = skus.id").where('skus.deleted is null').where("recommends.recommended_type = 'Sku'").where("recommends.id > #{max_id}").order('recommends.id desc')
      @updated_count = rs.length
      
      if  rs.length > 0
        $redis.set(key, rs.first.id) if rs.length > 0
      end
      
    end
  end


  def recommended_sku
    if @query == "" and not params[:cid] and not params[:category_id] and not params[:tag_id] and not params[:brand]
       rec_skus = Sku.joins("INNER JOIN recommends ON recommends.recommended_id = skus.id").where("skus.category_id < 100").where("skus.deleted is null").where('recommends.recommended_type' => "Sku").order("recommends.id desc").paginate(:page=>@page, :per_page=>@limit) if @page < 50
       get_updated_count if @page == 1
       return rec_skus
    end
  end

  def index
    #RubyProf.start if Rails.env == "development"
    pre
  
    q = @q
    if params[:street] and @street != ""
      q += " #{@street}"
    end
    
    if params[:mall] and @mall != ""
      q += " #{@mall}"
    end 

    if params[:brand] and @brand != ""
      q += " #{@brand}"
    end

    p_key = q.split(" ").join("_")

    if @index == "dapei"
      results = search_dapei
    else
      results = get_sphinx_result(q)
    end

    post

    hits = []
    @geo = {}
    @total_found = 0


    if results and results['matches']
       @total_found = results['total_found']
       if @total_found.to_i > 0
         #log_query
       end
       results['matches'].each do |doc|
         if @index == "comment"
           if not hits.include?(doc['attrs']['shop_id'])
             hits << doc['attrs']['shop_id']
           end
         else
           hits << doc['id']
         end
         if doc['attrs']['@geodist']
           if @index == "discount" or @index == "sku"
             @geo[doc['id']] = format_distance(doc['attrs']['@geodist'])
           else
             @geo[doc['attrs']['url']] = format_distance(doc['attrs']['@geodist'])
           end
         end
       end
    end
   
    if results
      @results = WillPaginate::Collection.create(@page,  @limit, results['total_found'].to_i>@mhit?@mhit:results['total_found'] ) do |pager|
        if @index == "comment"
          indexed_result = Shop.find_all_by_id(hits).index_by(&:id)
        else
          indexed_result = @index.capitalize.constantize.find_all_by_id(hits).index_by(&:id)
        end
        result = indexed_result.values_at(*hits)
        if @search_shop_by_item
          result = result.map{|item| item.shop if item}
          @index = "shop"
        end
        result.delete(nil)
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

          if @search_shop_by_item
            inst.cid = @cid
          end
        end
      end
    end
   

    #query_info
  
    #if Rails.env == "development"
      #result = RubyProf.stop
      # Print a flat profile to text
      #printer = RubyProf::FlatPrinter.new(result)
      #printer.print(STDOUT)
    #end
 
    session["user_return_to"]=request.path  
    respond_to do |format|
      if @debug
        format.html { render 'shops/search_debug.html' }
      end

      if @index == 'shop' or @index == "comment"
        @shops = @results
        format.html { render 'shops/index_all' }
      end
      
      if @index == 'item'
        @items = @results
        format.html { render 'items/index_all' }
      end

      if @index == 'discount'
        @discounts = @results
        format.html { render 'discounts/index_all' }
      end

      if @index == 'sku'
        @skus = self.recommended_sku if @sort=="hot"
        @skus = @results unless @skus
        @results = @skus.map{|sku| sku.wrap_item } if @old_index == 'item'
        format.html { render 'skus/index_all' }
      end

      if @index == "dapei" 
        if results
          @dapeis =  @results
          total_found = results['total_found'].to_s
          format.html { render 'dapeis/index_all', :layout=>"new_app" }
          format.json { render_for_api :dapei_list, :json => @results, :api_cache => 30.minutes, :meta => {:result=>"0", :updated_count => @updated_count.to_s, :limit => @limit.to_s,  :index=>@index, :total_found => total_found.to_s, :total_count => total_found.to_s } }
        end
      else
        total_found = 0
        total_found = results['total_found'] if results
        @results = [] if not results
        format.json { 
          render_for_api :public, :json => @results, :api_cache => 30.minutes, :meta => {:result=>"0", :updated_count => @updated_count.to_s, :limit => @limit.to_s, :index=>@index, :total_found => total_found.to_s, :total_count => total_found.to_s, :groups => @groups, :geo=>@geo } }
      end
    end
  end

  def setFilter
    $sphinx.ResetFilters()
    $sphinx.SetLimits(@offset, @limit)
 
    if @use_lnglat and @lng and @lat 
      lat = to_anchor( @lat.to_f )
      lng = to_anchor( @lng.to_f )
      $sphinx.SetGeoAnchor('lat_radians', 'long_radians', lat, lng);
      if @index == "item" or @index == "shop"
        $sphinx.SetFilterFloatRange('@geodist', 0.0, @radius);
      end
      if @index == "discount"
        $sphinx.SetFilterFloatRange('@geodist', 0.0, 5000000);
      end
      #$sphinx.SetSortMode(Sphinx::Client::SPH_SORT_EXTENDED, '@geodist ASC, @relevance DESC')
      #@sort = 'near' if @sort == ""
    end   
    
    if @index == "shop"
      $sphinx.SetFilterRange('shop_type', -1, 10)
    end  

 
    if @with_photo and  @index != "user"
      if @index == 'discount'
        #if not params[:level]
        #  @level = 1
        #end
        $sphinx.SetFilterRange('level', 0, 10)
        $sphinx.SetFilter('deleted', [0])
      else
        if params[:all]
          $sphinx.SetFilterRange('level', 0, 10)
        else
          $sphinx.SetFilterRange('level', @level, 10)
        end
      end
      #else
      #  if params[:level] and @level == 0 
      #      $sphinx.SetFilter('level', [@level.to_i])
      #  else
      #      $sphinx.SetFilterRange('level', @level, 10)
      #  end
      #end
    end
   
    if true
       if @low_price != "" and @high_price != ""
          SetPriceRange(@low_price.to_i, @high_price.to_i)
       elsif @high_price != ""
          SetPriceRange(0, @high_price.to_i)
       elsif @low_price != ""
          SetPriceRange(@low_price.to_i, 1000000)
       end
    end
    
 
    #if @index == "item" and params[:cid] and params[:cid] != "" 
    if params[:cid] and params[:cid] != "" 
      $sphinx.SetFilter('category_id', [@cid.to_i])
    end

    if @index == "item"
      $sphinx.SetFilterRange('ilevel', 3, 10)
      if @sku_id and @sku_id != ""
        $sphinx.SetFilter('sku_id', [@sku_id.to_i])
      end
    end

    if @index != "user" and @index != "sku" and @index != "brand"
      $sphinx.SetFilter('city_id', [@city_id.to_i])
    end

    if @index == "sku"
       $sphinx.SetFilterRange('category_id', 3, 100)
       $sphinx.SetFilterRange('ilevel', 4, 10)
    end  

    #filter 九海百盛
    #if @index != "user"
    #  $sphinx.SetFilter('mall_id', [2], true)
    #end

    if @index == "shop"
      $sphinx.SetFilterRange('items_count', 4, 1000000)
    end

    if @index == "discount"
      today =  -1.days.since(Date.today)
      $sphinx.SetFilterRange('end_date', today.to_datetime.to_i, 180.days.since(today).to_datetime.to_i)
    end

    #if @street != "" and @use_lnglat
    #  $sphinx.SetFilterFloatRange('@geodist', 0.0, 1000000)
    #end

    if @index == "item" and @sort != "near" 
      $sphinx.SetGroupBy('sku_id', Sphinx::Client::SPH_GROUPBY_ATTR, '@expr desc')
    end

    if @index == "discount"
    #  $sphinx.SetGroupBy('shop_id', Sphinx::Client::SPH_GROUPBY_ATTR, '@expr desc')
    end

    #for shop cid search
    if @index == "shop" and params[:cid] and params[:cid] != ""
       @search_shop_by_item = true
       @index = "item"
       $sphinx.SetGroupBy('shop_id', Sphinx::Client::SPH_GROUPBY_ATTR, '@expr desc')
    end
 
    if @index == "sku"
       setSkuFilter
    end
  end
  

  def SetPriceRange(low, high)
     @use_cache = false
     if @index == "item" or @index == "sku"
       $sphinx.SetFilterRange('refer_price', low, high)
     end
     if @index == "shop"
       $sphinx.SetFilterRange('low_price', low, high)
       $sphinx.SetFilterRange('high_price', low, high)
     end
  end
 
  def geoSearchAgain(q, radius)
    if not params[:radius]
      @radius = radius  
      setFilter 
      return $sphinx.Query(q, "#{@index};#{@index}_delta")       
    end
  end

  def index_dict
     {"baobei"=>"1", "yifu" =>"3", "xiezi"=>"4", "baobao"=>"5", "peishi"=>"6", \
      "nanzhuang" => "7", "tongzhuang" => "8", "shangyi" => "11", "kuzi" => "12", "qunzi" => "13",  "neiyi" => "14"}
  end

  def index_dict1
     {"baobei-shop"=>"1", "yifu-shop" =>"3", "xiezi-shop"=>"4", "baobao-shop"=>"5", "peishi-shop"=>"6", \
      "nanzhuang-shop" => "7", "tongzhuang-shop" => "8", "shangyi-shop" => "11", "kuzi-shop" => "12", "qunzi-shop" => "13",  "neiyi-shop" => "14"}
  end

  def index_dict2
     {"iyifu" =>"3", "ixiezi"=>"4", "ibaobao"=>"5", "ipeishi"=>"6", "inanzhuang" => "7", "itongzhuang" => "8", "ishangyi" => "11", "ikuzi" => "12", "iqunzi" => "13",  "ineiyi" => "14"}
  end

  def parse_option
    if params[:option]
      ops = ['']
      begin
         ops = params[:option].split('_')
      rescue =>e  
      end

      if index_dict.include?(params[:index])
         params[:cid] = index_dict[params[:index]]
         params[:index] = "item"
      end 

      if index_dict1.include?(params[:index])
         params[:cid] = index_dict1[params[:index]]
         params[:index] = "shop"
      end

      if index_dict2.include?(params[:index])
         params[:cid] = index_dict2[params[:index]]
         params[:index] = "sku"
      end 

      if ops.length == 2
         params[:q] = ops[1]
      end
      if  ops.length == 5
         if ops[1] == "street"
           params[:q] = ops[2]
           params[:sort] = ops[3] 
           params[:street] = ops[4]
         elsif ops[1] == "brand"
           params[:q] = ops[2]
           params[:sort] = ops[3] 
           params[:brand] = ops[4]
         end
      end
      if  ops.length >= 6
         if ops[1] == "street"
             params[:q] = ops[2]
             params[:sort] = ops[3]
             params[:street] = ops[4]
             params[:dp_id] = ops[5]
         elsif ops[1] == "mall"
             params[:q] = ops[2]
             params[:sort] = ops[3]
             params[:mall] = ops[4]
             params[:dp_id] = ops[5]
         elsif ops[1] == "brand"
             params[:q] = ops[2]
             params[:sort] = ops[3]
             params[:brand] = ops[4]
             params[:dp_id] = ops[5]
         elsif  ops[1] == "sb"
             params[:q] = ops[2]
             params[:sort] = ops[3]
             params[:street] = ops[4]
             params[:brand] = ops[5]
             params[:dp_id] = ops[6]
         else
             params[:index] = ops[1]
             params[:q] = ops[2]
             params[:sort] = ops[3]
             params[:cid] = ops[4]
             params[:dp_id] = ops[5]
         end
      end
      if ops.length == 4
         params[:q] = ops[1]
         params[:sort] = ops[2]
         params[:dp_id] = ops[3]
      end 

    end
  end
 
  def pre
    #parse_option
    @debug_info = ""
    @debug = false
    @updated_count = 0

    @query = ""
    @index = "shop"
    @offset = 0
    @limit = 12
    @mhit = 500
    @sort = ""
    @radius = 5000000
    @page = 1
    @dist_name = ""
    @dp_id = ""
    @cid = ""
    @street = ""
    @mall = ""
    @brand = ""
    @level = 4
    #@level = 2

    @with_photo = true
    @show_discount_status = true
    @use_cache = true   
    @reranking = true
    @search_shop_by_item = false
 
    #for shanghai temperaly
    @city_id = 1
    @lng = 121.487899   
    @lat = 31.249162
    @low_price = ""
    @high_price = ""

    @filter_attr = ""
    @filter_val = ""
 
    @filter_range_attr = ""
    @filter_min_val = ""
    @filter_max_val = ""

    @category_id = nil
    @category = ""

    @tag_id = nil
    @tag = "" 

    @sg = {}
    @mg = {}

    @color_group = {}
    @brand_group = {}
    @price_group = {}
    @source_group = {}
    @groups = {}

    if params[:city_id]
       @city_id = params[:city_id].to_i
    end

    if session[:city_id]
       @city_id = session[:city_id].to_i
    end

    if params[:debug]
      @debug = true
    end

    if params[:q]
      @query = params[:q]
      @query = @query.gsub("(null)", "")
    end
    if params[:offset]
      @offset = params[:offset].to_i
    end
   
    if params[:limit]
      @limit = params[:limit].to_i
    end

    if params[:page]
      @page =  params[:page].to_i
      @offset = (@page - 1)*@limit
    end

    if params[:index]
      @index = params[:index]
      @old_index = @index
    end
    if not ['shop', 'item', 'discount', 'dapei', 'comment', 'user', 'sku', 'brand'].include?(@index)
      @index = "shop"
    end

    if not ['shop', 'item', 'discount', 'sku'].include?(@index)
      @reranking = false
    end

    if params[:sort]
      @sort = params[:sort]
    end

    if params[:cid]
      @cid = params[:cid]
    end
   
    if params[:street]
      @street = params[:street]
    end

    if params[:mall]
      @mall = params[:mall]
    end

    if params[:brand]
      @brand = params[:brand]
    end

    if params[:level]
      @level = params[:level].to_i
    end

    
    if params[:aid]
      params[:dp_id] = params[:aid]
    end

    if params[:low_price]
      @low_price = params[:low_price]
    end

    if params[:high_price]
      @high_price = params[:high_price]
    end

    if params[:category_id]
      @category_id = params[:category_id]
      cat = Category.find_by_id( @category_id )
      @category = cat.name if cat
    end

    if params[:tag_id]
      @tag_id = params[:tag_id]
      tag = DapeiTag.find_by_id( @tag_id )
      @tag = tag.name if tag
    end

    if @index == 'sku' or  @index == 'item'
      @mhit = 1000
    end

    if @offset >= @mhit
      @offset = @mhit -1
    end
    
 
    @use_lnglat = false
    
    if params[:dp_id] and params[:dp_id].length >= 1
      if params[:dp_id][0,1] == "a"
        @dp_id = params[:dp_id][1,10]
      else
        @dp_id = params[:dp_id]
      end
     end
     
     if params[:lng] and params[:lat] and params[:lng].to_f > 0.00001 and params[:lat].to_f > 0.00001
       @lng = params[:lng]
       @lat = params[:lat]
       @use_lnglat = true
     end
     if params[:radius]
       @radius = params[:radius].to_f
     end

     ###### kill item index,use sku instead
     @index = "sku" if @index == 'item'
      
     if @index == "sku"
       @use_lnglat = false
     end

     $sphinx.SetSortMode(Sphinx::Client::SPH_MATCH_ALL)
     setFilter

     #if @sort == "" and @use_lnglat == false
     if @sort == ""
         if @index == "user" or @index == "brand" or @index == "comment"
           @sort = "new"
         else
           @sort = "hot"
         end
     end
     

     if @sort == "hot"
         expr = "level*0.1 + ln(items_count+1)*0.05 + ln(comments_count*5+likes_count*3+5*dispose_count+1) + 0.05*(updated_time - 1134028003)/45000 + 0.01*(created_time - 1134028003)/45000"
         if @index == "item"
             expr = "level*0.05 + 1.0*ln(comments_count*30+likes_count*5+dispose_count*10+1) + 0.05*(created_time - 1134028003)/45000"  
         end
         if @index == "discount"
             expr = "level*0.1 + 1.0*ln(comments_count*30+likes_count*5+dispose_count*20+1) + 0.1*(created_time - 1134028003)/45000"
         end
         if @index == "sku"
             expr = "level*0.5 + 1.0*ln(comments_count*30+likes_count*10+dispose_count+1 ) + 0.5*(created_time - 1134028003)/45000 + 0.01*(updated_time - 1134028003)/45000"
         end
         if @use_lnglat
             expr = expr + " - 10*ln(@geodist)"
         end
         $sphinx.SetSortMode(Sphinx::Client::SPH_SORT_EXPR, expr)
     end 

     
     if @sort == "new"
         #attr = "created_time"
         #if @index == "shop"
         #   attr = "updated_time"
         #end
         #$sphinx.SetSortMode(Sphinx::Client::SPH_SORT_ATTR_DESC, attr)
         expr = "(created_time - 1134028003)/45000 + 0.2*(updated_time - 1134028003)/45000"
         if @index == "shop"
            expr = "ln(items_count+1)*0.5 +0.4*(updated_time - 1134028003)/45000 + 0.1*(created_time - 1134028003)/45000"
         end
         if @use_lnglat
             expr = expr + "-50*@geodist"
         end
         $sphinx.SetSortMode(Sphinx::Client::SPH_SORT_EXPR, expr)
     end

     if @sort == "near" and @use_lnglat
         @reranking = false
         $sphinx.SetSortMode(Sphinx::Client::SPH_SORT_EXTENDED, '@geodist ASC, @relevance DESC')
     end
   
     #$sphinx.SetLimits(@offset, @limit)
     
     @q = ""
     if @query  != ""
       @q = "#{@query}"
     end

     #if @use_lnglat == false and @dist_name != "" and @street == ""
     if @dist_name != "" and @street == ""
       @q = "#{@query} #{@dist_name}"
     end

     if @category != ""
       @q = "#{@query} #{@category}"
     end

     if @tag != ""
       @q = "#{@query} #{@tag}"
     end
   
   end

   def groupByStreet
     if not params[:limit]
       params[:limit] = 30
     end
     pre
     getStreetGroup
     post
     respond_to do |format| 
       format.json { render_for_api :public, :json => [], :meta => {:index=>@index, :dat=>@sg } } 
     end 
  end

  def groupByMall
     pre
     getMallGroup
     post
     respond_to do |format|
       format.json { render_for_api :public, :json => [], :meta => {:index=>@index, :dat=>@mg } }
     end
  end

  def groupByBrand
     if not params[:limit] 
       params[:limit] = 30
     end
     pre
     getBrandGroup
     @bg = @bg.sort{|a,b| a["brand_name"]<=>b["brand_name"] }
     post
     respond_to do |format|
       format.json { render_for_api :public, :json => [], :meta => {:index=>@index, :dat=>@bg } }
     end
  end

  
  def area_city
     q = ""
     if params[:q]
       q = params[:q]
     end
     $sphinx2.ResetFilters
     if params[:lng] and params[:lat]
       lng = params[:lng]
       lat = params[:lat] 
       lat = to_anchor( lat.to_f )
       lng = to_anchor( lng.to_f )
       $sphinx2.SetGeoAnchor('lat_radians', 'long_radians', lat, lng)
       $sphinx2.SetSortMode(Sphinx::Client::SPH_SORT_EXTENDED, '@geodist ASC, @relevance DESC')
     end
     $sphinx2.SetFilterRange('level', 4, 10)
     results =  $sphinx2.Query(q.force_encoding("ASCII-8BIT"), "shop")
    
     if results and results['matches']
       results['matches'].each do |doc|
         @area = Area.city( doc['attrs']['city_id'] ).first
         break     
       end
     end
     respond_to do |format|
       @area.id = @area.city_id
       format.json { render_for_api :public, :json => @area, :meta => {:index=>"area" } }
     end 
  end

  

  def auto_suggest
     q = params[:q]
     if q != ""
       q = q.force_encoding("ASCII-8BIT")
     end
     results = $sphinx1.Query("*"+q+"*", "address")
     @res = []
     n = 0
     if results and results['matches']
       results['matches'].each do |doc|
         if n > 9
           break
         end
         if doc['attrs']['address'] != ""
           s = {}
           s['address'] = doc['attrs']['address'].force_encoding('UTF-8')
           s['docid']  = doc['attrs']['docid'].to_s
           @res << s
           n += 1
         end
       end
     end

     respond_to do |format|
       format.json { render_for_api :public, :json => [], :meta => {:dat=>@res } }
     end
  end


  def search_suggest
     q = params[:q]
     if q != ""
       q = q.force_encoding("ASCII-8BIT")
     end
     results = $sphinx1.Query("*"+q+"*", "query")
     @res = []
     n = 0
     #print results
     if results and results['matches']
       results['matches'].each do |doc|
         if n > 9
           break
         end
         if doc['attrs']['keyword'] != ""
           s = {}
           s['keyword'] = doc['attrs']['keyword'].force_encoding('UTF-8')
           @res << s
           n += 1
         end
       end
     end

     respond_to do |format|
       format.json { render_for_api :public, :json => [], :meta => {:dat=>@res } }
     end
  end


  def set_brand_type(bt)
    $sphinx.SetFilter('brand_type', [bt.to_i])
  end

 
  def set_price(pr)
    p = pr.split(',')
    SetPriceRange(p[0].to_i, p[1].to_i)
  end
  
  
  def set_source(src)
    @query = "#{@query} #{src}"
  end


  def setSkuFilter
    if params[:brand_type]
       set_brand_type(params[:brand_type])
    end 
    if params[:price]
       set_price(params[:price])
    end
    if params[:source]
       set_source(params[:source]) 
    end
  end

  def get_domain_name(domain)
    domain = domain.gsub(/^(.*?)\./, '')
    dd = {"tmall.com"=>"天猫", "yintai.com" => "银泰", "randa-cn.com" => "RANDA", "hm.com"=>"H&M", "ochirly.com"=>"欧时力", "net-a-porter.com" => "颇特女士"}
    if dd[domain]
      dd[domain]
    else
      domain.gsub(/\.(.*?)$/, '').upcase
    end
  end

  def getSkuGroup
    @groups = []
    @color_group = {}
    @brand_group = {}
    @price_group = {}
    @source_group = {} 

    #@color_group = { label:"颜色", data:[ {name:"color",value:"#505050"}, {name:"color", value:"#e7e7e7"}, {name:"color", value:"#828283"}, {name:"color", value:"#ead0cd"} ]}
    #@brand_group = { label:"品牌", data:[ {name:"brand_type", value:"1", label:"少淑装"}, {name:"brand_type", value:"2" ,label:"大淑装"},{name:"brand_type", value:"1", label:"少淑装"}, {name:"brand_type", value:"2" ,label:"大淑装"},{name:"brand_type", value:"1", label:"少淑装"}, {name:"brand_type", value:"2" ,label:"大淑装"} ]}
    @price_group = { label:"价格", data:[ {name:"price", value:"0,500", label:"0~500"}, {name:"price", value:"500,1000" ,label:"500~1000"}  ]}
    @source_group ={ label:"来源", data:[ {name:"source", value:"tmall.com", label:"天猫"}, {name:"source", value:"yintai.com" ,label:"银泰"}  ]}

    @brand_group['label'] = "品牌"
    bdict = {1=>"少淑装", 2=>"大淑", 5=>"潮牌", 6=>"设计师", 51=>"快时尚", 52=>"轻奢", 53=>"奢侈"}
    
    @brand_group['data'] = []
    if @brand_type_dict and  @source_dict and @price_dict
      @brand_type_dict = @brand_type_dict.sort_by{|k,v| -1*v} 
      @brand_type_dict[0, 10].each do |k, v|
        @brand_group['data'] << {name:"brand_type", value:"#{k}", label:"#{bdict[k]}"} 
      end
    
      @source_group['data'] = []
      @source_dict = @source_dict.sort_by{|k,v| -1*v } 
      @source_dict[0,10].each do |k, v|
        @source_group['data'] << { name:"source", value:"#{k}", label:"#{get_domain_name(k)}" }
      end

      @price_group['data'] = []
      @price_dict = @price_dict.sort_by{|k,v| k.split(',')[0].to_i }
      @price_dict.each do |k, v|
        @price_group['data']  << {name:"price", value:"#{k}", label:"#{k.gsub(/,/, '~')}"}
      end
    end 

    @groups << @brand_group
    #@groups << @color_group
    @groups << @price_group
    @groups << @source_group
    return @groups
  end
 


  def getStreetGroup
     $sphinx.SetGroupBy('street', Sphinx::Client::SPH_GROUPBY_ATTR, '@count desc')
     $sphinx.SetLimits(@offset, 10000)
     $sphinx.SetFilterRange('level', @level, 10)
     if @use_lnglat
       $sphinx.SetFilterFloatRange('@geodist', 0.0, 5000)
     end
     if @dist_name != ""
       @q = "#{@query} #{@dist_name}"
     end
     q = "#{@q}"
     if @brand != ""
       q = "#{@q} #{@brand}"
     end

     if @street != ""
       q = "#{@q} #{@street}"
     end
  
     q = q.force_encoding("ASCII-8BIT")
     results = $sphinx.Query(q, "#{@index};#{@index}_delta")

     @sg = []
     n = 0
     if results and results['matches']
       results['matches'].each do |doc|
         if n > 29
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
 
  def getMallGroup
     $sphinx.SetGroupBy('mall', Sphinx::Client::SPH_GROUPBY_ATTR, '@count desc')
     $sphinx.SetLimits(@offset, 10000)
     $sphinx.SetFilterRange('level', @level, 10)
     if @dist_name != ""
       @q = "#{@query} #{@dist_name}"
     end
     q = @q
     q = q.force_encoding("ASCII-8BIT")
     results = $sphinx.Query(q, "#{@index};#{@index}_delta")

     @mg = []
     n = 0
     if results and results['matches']
       results['matches'].each do |doc|
         if n > 29
           break
         end
         if doc['attrs']['mall'] != ""
           s = {}
           s['mall'] = doc['attrs']['mall'].force_encoding('UTF-8')
           s['count']  = doc['attrs']['@count'].to_s
           @mg << s
           n += 1
         end
       end
     end
  end

  def getBrandGroup
     $sphinx.SetGroupBy('brand_name', Sphinx::Client::SPH_GROUPBY_ATTR, '@count desc')
     $sphinx.SetLimits(@offset, 10000)
     $sphinx.SetFilterRange('level', @level, 10)
     if @use_lnglat
       $sphinx.SetFilterFloatRange('@geodist', 0.0, 5000)
     end

     if @dist_name != ""
       @q = "#{@query} #{@dist_name}"
     end
     q = "#{@q}"
     if @street != ""
       q = "#{@q} #{@street}"
     end
     if @brand != ""
       q = "#{@q} #{@brand}"
     end
      
     q = q.force_encoding("ASCII-8BIT")
     results = $sphinx.Query(q, "#{@index};#{@index}_delta")

     @bg = []
     n = 0
     if results and results['matches']
       results['matches'].each do |doc|
         if n > 29
           break
         end
         if doc['attrs']['brand_name'] != ""
           s = {}
           s['brand_name'] = doc['attrs']['brand_name'].force_encoding('UTF-8')
           s['count']  = doc['attrs']['@count'].to_s
           @bg << s
           n += 1
         end
       end
     end
  end
 
   
  def post
     $sphinx.ResetFilters()
     $sphinx.ResetGroupBy()
  end

  def query_info
     @query_info = {}
     @show_mall_info = false
     @show_street_info = false
     mall = nil
     if @query and @query != ""
        mall = Mall.find_by_name(@query) 
     end
     if @mall and @mall != ""
        mall = Mall.find_by_name(@mall)
     end

     if mall != nil
       @query_info["type"] = "mall"
       @query_info["obj"] = mall
       if mall.get_current_discount || mall.introduction 
          @show_mall_info = true
       end
     end
  end

end
