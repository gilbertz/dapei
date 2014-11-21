# -*- encoding : utf-8 -*-
#encoding: utf-8
class Manage::SkusController < Manage::BaseController

  #处理标签
  def add_tags_rake

    puts params[:sku_id].inspect
    puts "====================="

    Sku.calculate_add_tags(params[:sku_id])

    render :json => {result: 0}
  end

  #处理分类
  def add_categories_rake
    Sku.calculate_add_tags(params[:sku_id])

    render :json => {result: 0}
  end

  def index
    cond = "1=1"
  
    if params[:cid].to_i < 20
      cond += " and skus.category_id = #{params[:cid]}" unless params[:cid].blank?
    else
      cond += " and skus.sub_cat_id = #{params[:cid]}" unless params[:cid].blank?
    end

    @brand_name = params[:brand_name_cont]
    cond += " and brands.name like '%#{params[:brand_name_cont]}%'"

    params[:brand_id] && cond += " and brand_id = #{params[:brand_id]}"
    params[:today] && cond += " and created_at >= '#{Time.now.strftime("%Y-%m-%d")}' and level <= 5"

    @tag = params[:tag]
    @selected_category = params[:cid]
    @collections = Item.where(:category_id => 1000).order("created_at desc").limit(10) 


    unless params[:tag].blank?
      @q = Sku.includes([:photos,:brand]).tagged_with(params[:tag].split(",")).where(cond).ransack params[:q]
    else
      @q = Sku.where(cond).includes([:photos,:brand]).ransack params[:q]
    end

    @skus = @q.result.order('skus.id desc').page(params[:page]).per(108)

    @first_categories_for_select = Category.get_first_active_categories.collect{|c| [c.name, c.id] }

    @active_categories_for_select = Category.get_active_categories.collect{|c| [c.star_name, c.id] }

    @all_tags = Tag.all

    @levels_for_select = [["选择level"]]+(1..10).to_a

    unless params[:index].blank?
      render template: "manage/skus/index"
    else
      render template: "manage/skus/index2"
    end

  end

  def cancel

    unless params[:redis].blank?

      $redis.lrem("sku_to_be_shown", -1, params[:id])

    else
      recommend = Recommend.find_by_recommended_type_and_recommended_id("Sku", params[:id] )

      unless recommend.blank?
        recommend.destroy
        recommend.save
      end
    end


    redirect_to :back

  end

  def showing

    page = params[:page] || 1

    page = page.to_i

    @next_page = page + 1

    @prev_page = page - 1

    if @prev_page <= 0
      @prev_page = 1
    end

    if params[:w].to_i == 1
      render :template => "manage/skus/wait_showing"
    end

  end

  def edit
    @collections = Item.where(:category_id => 1000).order("created_at desc").limit(50)    

    @sku = Sku.find params[:id]
    @brands = Brand.order("url asc").collect {|b| [b.name,b.id] }
    @categories = Category.where({:parent_id => 1}).select([:name,:id]).collect {|c| [c.name,c.id] }
    @sub_categories = Category.where(:parent_id => @sku.category_id).collect {|c| [c.name,c.id] }
  end

  def recommends
    @c_selects = {
      "3"  => "未分类", "4"  => "鞋子", "5"  => "包包",
      "6"  => "配饰",   "7"  => "男装", "8"  => "童装",
      "9"  => "美妆",   "11" => "上衣", "12" => "裤装",
      "13" => "裙装",   "14" => "内衣"
    }
    
    if params[:dapei_id]
      @item = Item.find_by_url params[:dapei_id]
      @is_collection = true
      @skus = @item.get_skus
    else
      cond = "1=1"
      order = "id desc"
      order = "likes_count desc" if params[:order] and params[:order] == 'hot'
      params[:cid] && cond = "skus.category_id = #{params[:cid]}"
      params[:brand_id] && cond = "skus.brand_id = #{params[:brand_id]}"
      @skus = Sku.where(cond).order(order).limit(500)
    end
  end

  def with_or_without_data_brands
    @with_or_without = params[:with_or_without]
    brands = Brand.order{created_at.desc}
    withoutdata_brand_ids = []
    withdata_brand_ids = []
    brands.each do |brand|
      brand_skusdata = brand.category_skus
      case @with_or_without
      when /withdata/
        if brand_skusdata && !brand_skusdata.empty?
          withdata_brand_ids << brand.id
        end
      when /withoutdata/
        if brand_skusdata.nil? || brand_skusdata.empty?
          withoutdata_brand_ids << brand.id
        end
      end
    end
    query_str = params[:q].nil? ? nil : params[:q].to_downcase
    if !withdata_brand_ids.empty?
     @q = Brand.where{id>>withdata_brand_ids}.ransack query_str
     @brands = @q.result.order{last_updated.desc}.page(params[:page]).per(50)
    end
    if !withoutdata_brand_ids.empty?
     @q = Brand.where{id>>withoutdata_brand_ids}.ransack query_str
     @brands = @q.result.order{last_updated.desc}.page(params[:page]).per(50)
    end

  end
      
  def recommend_sku
    unless Recommend.find_by_recommended_type_and_recommended_id("Sku", params[:id] )
      key = "sku_to_be_shown"
      $redis.lpush(key, params[:id])

      puts "------------"

      if params[:pid]
        photo = Photo.find_by_id( params[:pid] )
        photo.is_send = 1 if photo
        photo.save
      end

      render json: { msg: "OK！~~~成功~~~" }
    else
      render json: { msg: "Warn!~~~已经推荐过~~~" }
    end
  end


  def update
    @sku = Sku.find params[:id]
    if params[:sku][:collection_id]
      item = Item.find_by_id( params[:sku][:collection_id] )
      item.relations.create(:target_id => @sku.id, :target_type => "Sku") if item
      params[:sku].delete :collection_id
    end
    @sku.update_attributes! params[:sku]
    redirect_to "/manage/skus"
  end

  def destroy
    @sku = Sku.find params[:id]
    @sku.deleted = true
    @sku.save
    render nothing: true
  end

  def check
    total_skus = Sku.maximum(:id)

    min_id = Sku.where(["created_at > ?", 3.months.ago]).order("id desc").last.try(:id)

    if min_id.blank?
      min_id = 0
    end

    ids = (min_id..total_skus).to_a.sample(500)

    @skus = Sku.where(:id => ids).first(100)
  end


  def ajax_update_edit
    @skus = Sku.where(:id => params[:sku_id])

    result = ""

    unless params[:first_category_id].blank?
      @skus.update_all(:category_id => params[:first_category_id])
      result << "一级分类修改"
    end

    unless params[:sub_category_id].blank?
      @skus.update_all(:sub_category_id => params[:sub_category_id])
      result << "二级分类修改"
    end

    unless params[:collection_id].blank?
      #@skus.update_all(:collection_id => params[:collection_id])
      @skus.each do |sku|
        item = Item.find_by_id( params[:collection_id] )
        item.relations.create(:target_id => sku.id, :target_type => "Sku") if item
        result << "加入选集修改"
      end
    end

    unless params[:tag_list].blank?
      sku = @skus.first
      sku.tag_list = params[:tag_list]
      sku.save
      result << "标签修改"
    end

    unless params[:brand_level].blank?

      @skus.each do |sku|
        brand = sku.brand
        unless brand.blank?
          brand.level = params[:brand_level]
          brand.save
        end
      end

      result << "brand level 修改"
    end

    unless params[:sku_level].blank?
      @skus.update_all(:level => params[:sku_level])
      result << "SKU level 修改"
    end
    @skus.update_all(:is_checked => 1)


    render :json => {result: "#{result} OK!"}

  end

  def sub_category

    if params[:m] == "1"
      @next_page_url = "/manage/skus/sub_category?1=1&m=1"
    else
      @next_page_url = "/manage/skus/sub_category?1=1"
    end

    unless params[:np].blank?
      @next_page_url += "&np=1"
    end

    unless params[:theoutnet].blank?
      @next_page_url += "&theoutnet=1"
    end

    page = (params[:page] || 1).to_i

    limit = 80

    unless params[:category_id].blank?
      $sphinx.SetFilter('category_id', [params[:category_id].to_i])
      @next_page_url += "&category_id=#{params[:category_id]}"
      @category_id = params[:category_id]
    end

    unless params[:sub_category_id].blank?
      $sphinx.SetFilter('sub_category_id', [params[:sub_category_id].to_i])
      sc = Category.find_by_id( params[:sub_category_id] )
      @category_id = sc.parent.id if sc and sc.parent 
      @next_page_url += "&sub_category_id=#{params[:sub_category_id]}"
    end


    unless params[:m]

      w = "category_id < 1000"

      $sphinx.ResetFilters


      unless params[:t].blank?
        #$sphinx.SetFilterRange('end_date', today.to_datetime.to_i, params[:t].to_i.days.since(today).to_datetime.to_i)
      end

      offset = limit * (page - 1)

      $sphinx.SetLimits(offset, 80)
      hits = []

      $sphinx.SetSortMode(Sphinx::Client::SPH_SORT_EXPR, "id")

      @query_str = ""

      unless params[:np].blank?
        @query_str = "net-a-porter"
      end

      unless params[:theoutnet].blank?
        @query_str = "theoutnet"
      end

      results = $sphinx.Query(@query_str, "sku_photos;sku_photos_delta")

      results['matches'].each do |doc|
        hits << doc['id']
      end

      @skus = Sku.where(:id => hits).all

    else
      q = nil
      
      s = Searcher.new("", "matter", q, nil, limit, page, @category_id.to_i)
      if params[:sub_category_id]
        s.set_sub_category_id(params[:sub_category_id])
      end
      s.remove_level(1)
      s.set_level(0)
      if params[:level]
        s.set_level(params[:level])
      end

      matters = s.search()
      @skus = []
      matters.each do |m|
        @skus << m.sku if m and m.sku
      end
    end
   

   #@skus = Sku.joins("left join `photos` on `skus`.`id` = `photos`.`target_id` and `photos`.`target_type`='Sku'").where("photos.is_send = 1").where(w).uniq.order("skus.id desc").offset(offset).limit(80)

    if @skus.length > 0
      @next_page_url += "&page=#{page + 1}"
    else
      @next_page_url += "&page=#{page}"
    end

    unless params[:sub_category_id].blank?
      c = Category.find_by_id(params[:sub_category_id])
      @category_id = c.parent_id if c
    end

    @categories = Category.get_first_categories.collect{|c| [c.name, c.id] }
    @sub_categories = Category.get_all_sub_categories(params[:category_id].to_i).collect{|c| [c.name, c.id] }
  end

  def sub_category_date

    if params[:t].blank?
      t = 7
    else
      t = params[:t].to_i
    end

    con = "category_id < 1000"

    unless params[:category_id].blank?
      con += " and skus.category_id = #{params[:category_id]}"
    end

    unless params[:sub_category_id].blank?
      con += " and skus.sub_category_id = #{params[:sub_category_id]}"
    end

    @skus = Sku.joins("left join matters on matters.sku_id = skus.id").where(con).where("matters.created_at >= ?", t.days.ago.strftime("%Y-%m-%d %H:%M:%S")).order("matters.id desc").page(params[:page]).per(80)

    @categories = Category.get_first_categories.collect{|c| [c.name, c.id] }
    @sub_categories = Category.get_all_sub_categories(params[:category_id].to_i).collect{|c| [c.name, c.id] }
  end

  def get_sub_categories
    @categories = Category.get_all_sub_categories(params[:first_category_id])

    render :partial => "category"
  end

  def tag
    @tags = Tag.all.collect{|tag| tag.name}
    render :json => @tags
  end

end
