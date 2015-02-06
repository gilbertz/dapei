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
  attr_accessor :index
  attr_accessor :limit
  attr_accessor :page
  attr_accessor :cid
  attr_accessor :sort
  attr_accessor :sphinx
  attr_accessor :bg

  def initialize(index, query=nil, sort=nil, limit=10, page=1)
    @query = query.gsub("(null)", "") if query
    @index = index
    @page = page.to_i
    @page = 1 unless page

    @cid = nil
    @sort = sort
    @brand_id = nil

    @level = 4
    @limit = limit.to_i
    @limit = 10 unless limit

    @offset = (@page.to_i - 1) * @limit.to_i
    @mhit = 5000
    @count = 0
    @reranking = false
    @rgb = nil

    @bg = []
    @sg = []

    @sphinx = $sphinx
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

  def set_user(su)
    following_users = su.following_by_type('User')
    user_ids = following_users.map { |u| u.id }
    @sphinx.SetFilter('user_id', user_ids)
  end

  def set_exclude_user_id(uid)
     @sphinx.SetFilter('user_id', [uid.to_i], true)
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

  def set_category_id(cid)
    @cid = cid
    @sphinx.SetFilter('category_id', [cid.to_i])
  end

  def set_sub_category_id(cid)
    @sphinx.SetFilter('sub_category_id', [cid.to_i])
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
    @total_found = 0

    if results and results['matches']
       @total_found = results['total_found']
       results['matches'].each do |doc|
         hits << doc['id']
       end
    end 
   
    if results and results['total_found']
      @results = WillPaginate::Collection.create(@page,  @limit, results['total_found'].to_i > @mhit? @mhit : results['total_found'] ) do |pager|
        indexed_result = @index.capitalize.constantize.find_all_by_id(hits).index_by(&:id)
        result = indexed_result.values_at(*hits)
        pager.replace(result)
      end
    end
    @results
  end

  def setFilter
    post
    @sphinx.SetLimits(@offset, @limit, @mhit)
 
    if (@index == "matter") and @cid and @cid != nil and @cid != 0
      if @cid.is_a?(Integer) and (@cid.to_i > 1000)
        if @parent_id == 9 or @parent_id == 10
          @sphinx.SetFilter('sub_category_id', to_array(@cid) )
        else
          @sphinx.SetFilter('category_id', to_array(@cid) )
        end
      elsif @cid.to_i == 100 and User.current_user
        #for self matters
        @sphinx.SetFilter('category_id', to_array(@cid) )
        @sphinx.SetFilter('user_id', [User.current_user.id])
      else 
        @sphinx.SetFilter('category_id', to_array(@cid) )
      end
    end

    if @brand_id != nil
      @sphinx.SetFilter('brand_id', [@brand_id.to_i])
    end

    #if @index == "matter"
    #  @sphinx.SetFilter('cut', [1])
    #end

    if @index == "dapei"
      @sphinx.SetFilterRange('level', 2,  10)
    end

  end
  
 
  def init
     post
     @sphinx.SetSortMode(Sphinx::Client::SPH_MATCH_ALL)
     setFilter

     if @sort == ""
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
         if @index == "item"
             expr = "level*0.05 + 1.0*ln(comments_count*30+likes_count*5+dispose_count*10+1) + 0.2*(created_time - 1134028003)/45000"  
         end

         if @index == "matter"
             expr = "(created_time - 1134028003)/45000"
         end

         @sphinx.SetSortMode(Sphinx::Client::SPH_SORT_EXPR, expr)
     end 

     if @sort == "sale" and ( @index == "item" or @index == "sku")
         expr = "0.1 * ( 100 - off_percent ) + (created_time - 1134028003)/45000"
         @sphinx.SetFilterRange('off_percent', 5,  99)
         @sphinx.SetSortMode(Sphinx::Client::SPH_SORT_EXPR, expr)
     end
     
     if @sort == "new"
         expr = "(created_time - 1134028003)/45000 + 0.2*(updated_time - 1134028003)/45000"
         @sphinx.SetSortMode(Sphinx::Client::SPH_SORT_EXPR, expr)
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
     @bg = []      
     q = "#{@query}".force_encoding("ASCII-8BIT")
     results = @sphinx.Query(q, "#{@index};#{@index}_delta")
     #p results

     n = 0
     if results and results['matches']
       results['matches'].each do |doc|
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
