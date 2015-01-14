# -*- encoding : utf-8 -*-
require 'will_paginate/array'

class DapeisController < ApplicationController
  layout "new_app"
  #caches_action :get_dp_items, :if => Proc.new { |c| p c.request.params[:page].to_i == 1 }

  before_filter :remove_token, :only => [:index]
  before_filter :authenticate_user!, :only => [:new, :create, :destroy]
  #load_and_authorize_resource :dapei, :find_by=>:id
  #load_and_authorize_resource :except => [:create, :new]

  respond_to :html, :json

  def new
    @dapei = Dapei.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @dapei }
    end
  end


  # new dapei detail for app
  def get_dapei_detail

    @comment_page = 1
    @comment_limit = 50
    @comment_limit = params[:comment_limit].to_i if params[:comment_limit]
    @comment_page = params[:comment_page].to_i if params[:comment_page]

    @like_page = 1
    @like_limit = 8
    @like_page = params[:like_page].to_i if params[:like_page]
    @like_limit = params[:like_limit].to_i if params[:like_limit]

    @dapei = Item.by_url(params[:dapei_id])

    if @dapei
      @dapei.incr_dispose

      @comments_count = Comment.cache_comments_count_by_target(@dapei)
      @comments = Comment.cache_comments_by_target(@dapei, @comment_page, @comment_limit)
      @comments = Comment.dup(@comments)
      user_id = current_user.id if current_user
      @like_users_count = Like.cache_likes_users_count_by_target(@dapei)
      @like_users = Like.cache_likes_users_by_target(@dapei, @like_page, @like_limit, user_id)

    end

  end

  def dup()
    uids = {}
    dps = []
    @dapeis = @dapeis.compact.sort_by { |d| d.level.to_i*-1 }
    @dapeis.each do |d|
      if uids[d.user_id].to_i < 2
        dps << d
      end
      uids[d.user_id] = uids[d.user_id].to_i + 1
    end
    @dapeis = dps
  end


  
  def recommend
    @dapei = Dapei.find_by_url(params[:id])
    @dapei.recommend
    respond_to do |format|
      format.html { redirect_to :back }
      format.json {render :json=>{:result=>"0"}}
    end
  end

  def unrecommend
    @dapei = Dapei.find_by_url(params[:id])
    @dapei.unrecommend
    respond_to do |format|
      format.html { redirect_to :back }
      format.json {render :json=>{:result=>"0"}}
    end
  end



  def recommended
    @page = 1
    @page = params[:page].to_i if params[:page]
    @limit = 8
    @limit = params[:limit].to_i if params[:limit]

    @dapeis = []
    if params[:sku_id]
      sku = Sku.find_by_id(params[:sku_id])
      @dapeis = sku.get_dapeis(@limit, @page) if sku
    elsif params[:brand_id]
      brand = Brand.find_by_id(params[:brand_id])
      @dapeis = brand.get_dapeis(@limit, @page) if brand
    elsif params[:dapei_id]
      dp = Dapei.find_by_url(params[:dapei_id])
      @dapeis = dp.get_dapeis(@limit, @page) if dp
    end
    @count = @dapeis.length
    respond_to do |format|
      format.html { render 'index_all', :layout => "new_app" }
      format.json { render_for_api :dapei_list, :json => @dapeis, :meta => {:result => "0", :total_count => @count.to_s, :updated_count => "0"} }
    end
  end

  def get_updated_count(did)
    if current_user
      key = "dapei_view_at_#{current_user.id}"
      if $redis.get(key)
        last_view_at = $redis.get(key)
        cond = "id > #{last_view_at} and id <= #{did}"
        @updated_count = Dapei.where("level >= 2").where(cond).count
      end
      $redis.set(key, did)
    end
  end

  def get_max_id(dapeis)
    max_id = 0
    dapeis.each do |dp|
      max_id = dp.id if dp.id > max_id
    end
    max_id
  end


  def theme
    @dapei_tag = DapeiTag.find params[:theme_id]
    @dapeis=Dapei.joins(:dapei_info).where("`items`.category_id = 1001").where("`dapei_infos`.dapei_tags_id=#{params[:theme_id]}").order("created_at desc")
    respond_to do |format|
      format.html { render 'index_all', :layout => "new_app" }
      format.json { render_for_api :theme_list, :json => @dapeis, :meta => {:theme => @dapei_tag.to_json, :result => "0", :total_count => @dapeis.count.to_s} }
    end
  end

  #html5 页面
  def theme_view

    @dapei_tag = DapeiTag.find params[:theme_id]
    @dapeis=Dapei.joins(:dapei_info).where("`items`.category_id = 1001 or `items`.category_id = 1000").where("`dapei_infos`.dapei_tags_id=#{params[:theme_id]}").order("created_at desc")

    render :layout => false
  end


  def index
    @index = "dapei"
    @page = 1
    @page = params[:page].to_i if params[:page]
    @limit = 5
    @limit = params[:limit].to_i if params[:limit]
    @updated_count = 0

    @order = "hot"
    @order = params[:order] if params[:order]

    if true
      if params[:all]
        @dapeis=Dapei.joins(:dapei_info).where("`items`.category_id = 1001").order("created_at desc").page(params[:page]).per(@limit)
        @count=Item.where(:category_id => "1001").count
      elsif params[:theme_id]
        @count = Dapei.joins(:dapei_info).where("`items`.category_id = 1001").where("`dapei_infos`.dapei_tags_id=#{params[:theme_id]}").count
        @dapeis=Dapei.joins(:dapei_info).where("`items`.category_id = 1001").where("`dapei_infos`.dapei_tags_id=#{params[:theme_id]}").order("created_at desc").page(params[:page]).per(@limit)

        #统计每日主题数据
        monitor_record

      elsif params[:tag]
        dapei_infos = DapeiInfo.joins(:dapei).tagged_with(params[:tag]).order("created_at desc").paginate(:page => params[:page], :per_page => @limit)
        @count = DapeiInfo.joins(:dapei).tagged_with(params[:tag]).count
        @dapeis = dapei_infos.map(&:dapei)
      else
        cond = "items.level >= 2"
        cond = "items.level >= 0 or items.level is null" if @order == 'new'
        if current_user and @order == "follow"
          @following_users = current_user.following_by_type('User')
          user_ids = @following_users.map { |u| u.id }
          user_ids << current_user.id
          cond = {:user_id => user_ids}
        end

        @dapeis=Dapei.joins(:dapei_info).where(cond).where("`items`.category_id = 1001").order("created_at desc").page(params[:page]).per(@limit)
        @count = Dapei.joins(:dapei_info).where(cond).count
        get_updated_count(get_max_id(@dapeis)) if @page == 1
        dup
      end

      if not params[:theme_id]
        #  if @page == 1
        #    @showing_dapeis = Dapei.showing
        #    if @showing_dapeis and @showing_dapeis.length > 0
        #      @dapeis = @showing_dapeis + @dapeis
        #      @count += @showing_dapeis.length
        #    end
        #  end
        @dapeis = WillPaginate::Collection.create(@page, @limit, @count) do |pager|
          pager.replace @dapeis
        end
      end
      session["user_return_to"]=dapeis_path

      #if stale?(:etag => @last_dapei,  :last_modified => @last_dapei.updated_at )
      respond_to do |format|
        format.html { render 'index_all', :layout => "new_app" }
        format.json { render_for_api :dapei_list, :json => @dapeis, :meta => {:result => "0", :total_count => @count.to_s, :updated_count => @updated_count.to_s} }
        #format.json { render json: @items }
      end
      #end
    end
  end

  def collections
    @page = 1
    @page = params[:page].to_i if params[:page]
    @limit = 5
    @limit = params[:limit].to_i if params[:limit]

    @cols = Collection.joins(:dapei_info).where("`items`.level >= 2").order("created_at desc").page(@page).per(@limit)
    @count = Collection.where("`items`.level >= 2").count
    @updated_count = 0

    respond_to do |format|
      format.html { render 'index_all', :layout => "new_app" }
      format.json { render_for_api :collection_list, :json => @cols,:root => 'dapeis', :meta => {:result => "0", :total_count => @count.to_s, :updated_count => @updated_count.to_s} }
    end
  end

  def collections_rabl
    @page = 1
    @page = params[:page].to_i if params[:page]
    @limit = 5
    @limit = params[:limit].to_i if params[:limit]

    @cols = Dapei.joins(:dapei_info).where("`items`.level >= 2").where("`items`.category_id = 1000").order("created_at desc").page(@page).per(@limit)
    @count = Item.where("`items`.level >= 2").where(:category_id => 1000).count
    @updated_count = 0
  end

  def sim(c1, c2)
    return (c1.to_i(16) >= c2.to_i(16) - 1 and c1.to_i(16) <= c2.to_i(16) + 1)
  end

  def similar_color(color1, color2)
    color1 = color1.gsub('#', '')
    color2 = color2.gsub('#', '')
    return false if color1.length < 6 or color2.length < 6
    return (sim(color1[0], color2[0]) and sim(color1[2], color2[2]) and sim(color1[4], color2[4]))
  end

  def by_item
    if current_user
      current_user.set_dapei_classroom_read
    end

    @index = "dapei"
    @page = 1
    @page = params[:page].to_i if params[:page]
    @limit = 8
    @level = 10
    @cid = nil
    @sub_category_id = nil
    @tag_id = nil
    @tag_name = nil
    @tag = {}
    @cover = {}

    @cid = params[:cid] if params[:cid]
    @tag_id = params[:tag_id] if params[:tag_id]
    @sub_category_id = params[:sub_category_id] if params[:sub_category_id]
    @color = params[:color] if params[:color]

    if @tag_id
      tag = Tag.find_by_id(@tag_id)
      if tag
        @tag_name = tag.name
        cname = Category.find_by_id(@sub_category_id).name

        desc_tag = DescTag.find_by_category_id_and_tag_id(@sub_category_id, @tag_id)
        desc = @tag_name + @category_name.to_s
        desc = desc_tag.desc.to_s if desc_tag
        @tag = {:id => @tag_id, :desc => desc.to_s}
      end
    end


    p_key = "dp_classroom_#{@cid}_#{@tag_id}_#{@sub_category_id}_#{@color}_#{@limit}_#{@page}"
    #p p_key
    res_dict = Rails.cache.fetch "dapeis_#{p_key}", :expires_in => 30.minutes do
      res_dict = {}

      s = Searcher.new("", "matter", @tag_name, nil, @limit, @page, @cid)
      s.set_color(@color) unless @color.blank?
      s.set_level(@level)
      s.set_sub_category_id(@sub_category_id) if @sub_category_id

      @matters = s.search()
      @count = s.get_count
      @skus = []
      @colors = []
      @dapeis = []

      @matters.each do |m|
        next if m.blank?
        skip = false
        unless @color.blank?
          if similar_color(m.get_first_color, @color) or similar_color(m.get_second_color, @color)
            skip = false
          else
            skip = true
          end
        end
        unless skip
          @skus << m.sku
          @dapeis += m.sku.get_sku_dapeis
        end
      end

      if @skus.length > 0
        first_sku = @skus.first
        @cover = {:img_url => first_sku.img_url(:normal_medium), :color => first_sku.get_color}
      end

      @items = @skus.map { |item| {:id => item.id, :title => item.title, :img_url => item.img_url(:normal_medium), :tags => item.tag_list} }
      @dapeis = @dapeis.uniq

      colors = []
      #if params[:color].blank?
      if true
        @skus.each do |s|
          color = s.get_color
          unless colors.include? color
            @colors << {:id => s.id, :img_url => s.img_url(:normal_medium), :value => color, :value1 => s.get_color_1}
            colors << color
          end
        end
      end
      res_dict[:dapeis] = @dapeis
      res_dict[:cover] = @cover
      res_dict[:items] = @items
      res_dict[:colors] = @colors
      res_dict[:count] = @count
      res_dict
    end
    @dapeis = res_dict[:dapeis]
    @cover = res_dict[:cover]
    @items = res_dict[:items]
    @colors = res_dict[:colors]
    @count = res_dict[:count]

    @dapeis = WillPaginate::Collection.create(@page, @limit, @count) do |pager|
      pager.replace @dapeis
    end

    respond_to do |format|
      format.html { render 'index_all', :layout => "new_app" }
      format.json { render_for_api :dapei_list, :json => @dapeis, :meta => {:result => "0", :tag => @tag, :covel => @cover, :items => @items, :colors => @colors, :total_count => @count.to_s, :updated_count => "0"} }
    end

  end


  def create
    @dapei = Dapei.new(params[:dapei].merge(:user_id => current_user.id))
    if @dapei.save
      Photo.build_photo(current_user, params[:photos], params[:item_image], params[:item_image_type], @dapei.id, "Item")

      if params[:items]
        params[:items].each do |url|
          if url.strip != ""
            item = Item.find_by_url(url)
            if item
              @dapei.rel_items.create(:item_id => item.id)
            end
          end
        end
      end
      respond_to do |format|
        format.html { redirect_to "/dapeis/view/#{@dapei.url}" }
        format.json { render_for_api :public, :json => @dapei, :meta => {:result => "0"} }
      end
    else
      format.html { render :nothing => true, :status => 422 }
      format.json { render_for_api :error, :json => @dapei, :meta => {:result => "1"} }
    end
  end


  #def recommend_dapei
  #unless Recommend.find_by_recommended_type_and_recommended_id("Item", params[:id] )
  #@recommend = Recommend.new
  #@recommend.recommended_type="Item"
  #@recommend.recommended_id=params[:id]
  #@recommend.save
  #end
  #redirect_to :back
  #end

  #def show
  #@dapei = Dapei.find( params[:id] )
  #if @dapei
  #@items = @dapei.get_items
  #end
  #respond_to do |format|
  #format.html # show.html.erb
  #format.json { render json: @dapei }
  #end
  #end

  def view
    @index = "dapei"
    @item = Item.by_url(params[:url])
    @item = Dapei.get_star unless @item

    if @item.category_id == 1001
      @dapei = Dapei.by_url(params[:url])
    elsif @item.category_id == 1000
      @dapei = Collection.find_by_url(params[:url])
    elsif
      @dapei = @item
    end

    @dapei = Dapei.get_star unless @dapei

    respond_to do |format|
      format.html {
        @dapei_info = @dapei.dapei_info

        if @dapei_info.blank?
          redirect_to "/dapeis/index_all"
          return
        end

        @dapei_item_infos = @dapei_info.dapei_item_infos
        @dapei_item_infos = DapeiItemInfo.where("dapei_info_id = ? and sku_id != null", @dapei_info.id).all

        @dapei_get_items = @dapei.get_items

        @dapeis_by_this_user = Dapei.where("level >= 0").where(:user_id => @dapei.user_id, :category_id => 1001).limit(20)
        @comments = @dapei.comments.order('updated_at DESC').paginate(:page => params[:page], :per_page => 5)
        @like_users = @dapei.likes.order('created_at DESC').paginate(:page => params[:page], :per_page => 16).map(&:user)

        @comment = Comment.new
        @comment.commentable_type = "Item"
        @comment.commentable_id = @dapei.id

        session["user_return_to"]=dapei_view_path(@dapei)
        render 'view_show'
      }
      format.json {
        if @item.category_id == 1000
          render_for_api :collection_detail, :json => @dapei, :meta => {:result => "0"}
        else
          render_for_api :dapei_detail, :json => @dapei, :meta => {:result => "0"}
        end
      }
    end
  end

  def get_dp_items
    @dapei = Item.by_url(params[:url])
    @dapei = Dapei.get_star unless @dapei

    @page = 1
    @limit = 12
    @page = params[:page].to_i if params[:page]
    @limit = params[:limit].to_i if params[:limit]

    if @dapei and @dapei.category_id == 1000
      @dapei = Collection.find_by_url(params[:url])
    end
    dp_items_count = 0
    if @dapei
      @dp_items = @dapei.get_items(@page, @limit)
      #dp_items_count = @dapei.get_items_count
      dp_items_count = @dapei.get_items_count
      @dapei.incr_dispose
    end
    respond_to do |format|
      format.json { render_for_api :public, :json => @dp_items, :meta => {:result => "0", :total_count => dp_items_count.to_s} }
    end
  end


  def get_like_users
    @limit = 8
    @limit = params[:limit].to_i if params[:limit]
    @dapei = Dapei.by_url(params[:url])
    @dapei = Dapei.get_star unless @dapei

    p_key = "dapei_like_users_page_#{params[:page]}_limit_#{params[:limit]}_url_#{params[:url]}"
    p_key_count = "dapei_like_users_url_#{params[:url]}"

    @likes_count = 0
    if @dapei
      @like_users = Rails.cache.fetch "#{p_key}", :expires_in => 3.minutes do
        @dapei.likes.order('created_at DESC').paginate(:page => params[:page], :per_page => @limit).map(&:user)
      end

      @likes_count = Rails.cache.fetch "count_#{p_key_count}", :expires_in => 3.minutes do
        @dapei.likes_count
      end
    end
    respond_to do |format|
      format.json { render_for_api :public, :json => @like_users, :meta => {:result => "0", :total_count => @likes_count.to_s} }
    end
  end


  def recommended_star_dapeis
    # params
    # l = 5
    l = params[:l].to_i || 5
    l = 20 if l > 20

    @dapeis = Dapei.includes(:dapei_info).where("dapei_infos.is_star = 1").order("items.id desc").paginate(:page => params[:page], :per_page => l)

    total_pages = @dapeis.total_pages
    more_pages = total_pages - params[:page].to_i

    respond_to do |format|
      format.json { render_for_api :dapei_list, :json => @dapeis, :meta => {:result => "0", :more_pages => "#{more_pages}", :total_pages => "#{total_pages}"} }
    end
  end


  def promote
    @dapei = Dapei.find(params[:id])
    if @dapei
      @dapei.created_at = Time.now
      @dapei.save
    end
    render :text => "~~succ~~"
  end

  def like_dapei
    @dapei = Dapei.find_by_url(params[:id])
    if @dapei
      @dapei.rand_like(true)
    end
    respond_to do |format|
      format.html { redirect_to :back }
    end
  end


  def follow_dapei_author
    @dapei = Dapei.find_by_url(params[:id])
    if @dapei
      @dapei.rand_follow
    end
    respond_to do |format|
      format.html { redirect_to :back }
    end
  end

  def update
    @dapei = Dapei.find(params[:id])
    respond_to do |format|
      prev_level = @dapei.level.to_i
      if params[:dapei][:category_id].to_i == 1000
        params[:dapei][:type] = "Collection"  
      end
      if @dapei.update_attributes(params[:dapei])
        current_level = @dapei.level.to_i
        if prev_level == 0 and current_level >= 2
          @dapei.rand_like
          PushNotification.push_review_dapei(@dapei.get_user.id, @dapei.url)
        end
        if prev_level < 5 and current_level >= 5
          @dapei.rand_like
          PushNotification.push_star_dapei(@dapei.get_user.id, @dapei.url)
        end

        if @dapei.category_id == 1001
          if params[:start_date] and params[:end_date]
            @dapei.dapei_info.start_date = params[:start_date]
            @dapei.dapei_info.end_date = params[:end_date]
          end
          if params[:dapei_tags_id]
            @dapei.dapei_info.dapei_tags_id = params[:dapei_tags_id].to_i
          end
          @dapei.dapei_info.save
        end
        format.html { redirect_to :back }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @dapei.errors, status: :unprocessable_entity }
      end
    end
  end


  def edit
    @themes = DapeiTag.sub(99)
    @dapei_tags = ['轻熟', '少淑', '男人志']
    @dapei = Dapei.find(params[:id])
  end

  def destroy

    if params[:id]
      if params["id"].to_s.first == "-"
        @diid = params["id"].to_s.sub("-", "")
        @dapei_info = DapeiInfo.find(@diid)
      else
        @dapei = Dapei.find_by_url(params[:id])
        @dapei = Dapei.find_by_id(params[:id]) unless @dapei
      end
    end

    if @dapei
      @dapei.level = -1
      @dapei.deleted = true
      @dapei.save
      respond_to do |format|
        format.html { redirect_to :back }
        format.json { render :json => {:result => "0"} }
      end
    elsif @dapei_info
      @dapei_info.destroy
      respond_to do |format|
        format.html { redirect_to :back }
        format.json { render :json => {:result => "0"} }
      end
    else
      respond_to do |format|
        format.html { redirect_to :back }
        format.json { render :json => {:result => "1"} }
      end
    end
  end


  #选集的 html 页面
  def collection_show
    @collection = Item.where(:category_id => 1000).where(:url => params[:id]).first

    @total_page = (@collection.dapei_info.dapei_item_infos.count / 20.0).ceil

    @like_users = @collection.like_users
    render :layout => false
    
  end

  def collection_items
    collection = Item.where(:category_id => 1000).where(:url => params[:id]).first
    @dapei_item_infos = collection.dapei_info.dapei_item_infos.page(params[:page]).per(20).uniq.compact
  end

  def share_selfie
    @selfie = Item.where(:category_id => 1002).where(:url => params[:id]).first
    if @selfie
      @like_users = @selfie.like_users
    end
    render :layout => false
  end

end
