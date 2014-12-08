# -*- encoding : utf-8 -*-
#encoding: utf-8
class Manage::DapeisController < Manage::BaseController
  before_filter :set_param_side

  def index
    #@q = Dapei.includes([:dapei_info,:user]).ransack params[:q]
    #where("`items`.category_id = 1001 or `items`.category_id = 1000")
    if params[:theme_id]

      @q= Dapei.joins(:dapei_info).where("`dapei_infos`.dapei_tags_id=#{params[:theme_id]}").ransack params[:q]
    else
      @q = Dapei.ransack params[:q]
    end

    @items = @q.result.order('created_at desc').page(params[:page]).per(15)
    @falg = 0
  end

  def queue
    #@q = Dapei.includes([:dapei_info,:user]).ransack params[:q]
    #@q = Dapei.where(:category_id => [1000, 1001]).ransack params[:q]

    if params[:brand_id]
      @brand = Brand.find params[:brand_id]
      if @brand
        searcher = Searcher.new(nil, "dapei", @brand.name, "new")
        @dapeis = searcher.search()
      end
    else
      dp_urls = $redis.lrange('dp_to_be_shown', 0, -1)
      @dapeis = dp_urls.map { |url| Dapei.find_by_url url }
    end
    render "search_index"
  end

  def collections
    @q = Collection.ransack params[:q]
    # @q = Dapei.where(:category_id => 1000).ransack params[:q]
    @items = @q.result.order('created_at desc').page(params[:page]).per(15)
    @falg = 0
    render "index"
  end

  
  def selfies
    @q = Selfie.ransack params[:q]
    @items = @q.result.order('created_at desc').page(params[:page]).per(15)
    @falg = 1
    render "index"
  end


  def new
    @dapei = Dapei.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @dapei }
    end
  end

  def selfie_edit
    @selfie = Item.find_by_url params[:id]
  end

  def edit
    @meta_tags = MetaTag.all
    @themes = DapeiTag.sub(99)
    @dapei_tags = ['通勤OL', '复古名媛', '文艺森女', '甜美', '男神', '高街', '中性休闲', '性感熟女', '护肤', '彩妆', '香氛', '洗浴护体', '美发护发',
                   '卧室', '餐厅', '客厅', '浴室', '书房']

    @dapei = Item.find_by_url params[:id]
    @dapei_info = @dapei.dapei_info

    @users = []
    @users << @dapei.get_user
    @users += User.system_users
    @users += User.where("id > 20000").limit(200)
    @users_for_select = @users.collect { |c| [c.name, c.id] }

    render layout: false
  end

  def new_comment
    @dapei = Item.find_by_url params[:id]
    @users = User.system_users
    @users += User.where("id > 20000").limit(200)
    @users_for_select = @users.collect { |c| [c.name, c.id] }
    render layout: false
  end


  def recommend_star
    @dapei = Dapei.find_by_url(params[:id])
    @dapei.dapei_info.update_attribute(:is_star, 1)
    @dapei.save
    respond_to do |format|
      format.js
    end
  end


  def unrecommend_star
    @dapei = Dapei.find_by_url(params[:id])
    @dapei.dapei_info.update_attribute(:is_star, nil)
    @dapei.save
    respond_to do |format|
      format.js
    end
  end


  def update
    dapei = Dapei.find_by_url params[:id]
    if params[:meta_tags]
      dapei.meta_tag_id = params[:meta_tags]
      dapei.mtag_list = ""
      if params[:meta_tags].to_i >0
        dapei.mtag_list.add(MetaTag.find(params[:meta_tags]).tag)
        dapei.tag_list << dapei.mtag_list
      end     
      dapei.save
    end

    dapei_info = dapei.dapei_info
    pre_category_id = dapei.category_id
    if params[:tags]
      dapei_info.tag_list.add(params[:tags])
    end

    @once = true
    @once = true if params[:once] == "1"
    level_before = dapei.level.to_i
    level_now = params[:dapei][:level].to_i
    
    #unless @once
    #  current_level = params[:dapei][:level].to_i
    # $redis.set('level_' + dapei.url, params[:dapei][:level])
    # params[:dapei].delete :level
    #  if dapei.category_id == 1001
    #    $redis.lpush('dp_to_be_shown', dapei.url)
    #  else
    #    $redis.lpush('col_to_be_shown', dapei.url)
    #  end
    #end

    prev_level = dapei.level.to_i
    if dapei.update_attributes params[:dapei] and dapei_info
      dapei_info.dapei_tags_id = params[:dapei_tags_id]
      dapei_info.update_attributes params[:dapei_info]
      current_category_id = dapei.category_id
      if pre_category_id == 1001 and current_category_id == 1000
        dapei.dapei2collection
      end

      if @once
        current_level = dapei.level.to_i

        if prev_level == 0 and current_level >= 2
          dapei.rand_like
          PushNotification.push_review_dapei(dapei.get_user.id, dapei.url)
        end
        if prev_level < 5 and current_level >= 5
          dapei.rand_like
          PushNotification.push_star_dapei(dapei.get_user.id, dapei.url)
        end
      end

      if dapei.category_id == 1001 or dapei.category_id == 1000
        if params[:start_date]
          dapei.dapei_info.start_date = params[:start_date]
        end
        if params[:end_date]
          dapei.dapei_info.end_date = params[:end_date]
        end

        if params[:start_date_hour]
          dapei.dapei_info.start_date_hour = params[:start_date_hour]
        end

        if params[:dapei_tags_id]
          dapei.dapei_info.dapei_tags_id = params[:dapei_tags_id].to_i
        end
      end
      dapei.dapei_info.save
    end
    #dapei.find_brands
    if level_before != level_now
      dapei.show_date = dapei.updated_at
    end
    dapei.save
    redirect_to :back
    #redirect_to [:manage,:dapeis]
  end


   def selfy_update
    dapei = Selfie.find_by_url params[:id]
    if params[:meta_tags]
      dapei.meta_tag_id = params[:meta_tags]
      dapei.mtag_list = ""
      if params[:meta_tags].to_i > 0
        dapei.mtag_list.add(MetaTag.find(params[:meta_tags]).tag)
        dapei.tag_list << dapei.mtag_list
      end
      dapei.save
    end
    dapei_info = dapei.dapei_info
    pre_category_id = dapei.category_id
    if params[:tags]
      dapei_info.tag_list.add(params[:tags])
    end

    @once = false
    @once = true if params[:once] == "1"

    level_before = dapei.level.to_i
    level_now = params[:selfie][:level].to_i

    unless @once
      current_level = params[:selfie][:level].to_i
      $redis.set('level_' + dapei.url, params[:selfie][:level])
      params[:selfie].delete :level
      if dapei.category_id == 1001
        $redis.lpush('dp_to_be_shown', dapei.url)
      else
        $redis.lpush('col_to_be_shown', dapei.url)
      end
    end

    prev_level = dapei.level.to_i
    if dapei.update_attributes params[:selfie] and dapei_info
      dapei_info.dapei_tags_id = params[:dapei_tags_id]
      dapei_info.update_attributes params[:dapei_info]
      current_category_id = dapei.category_id
      if pre_category_id == 1001 and current_category_id == 1000
        dapei.dapei2collection
      end

      if @once
        current_level = dapei.level.to_i

        if prev_level == 0 and current_level >= 2
          dapei.rand_like
          PushNotification.push_review_dapei(dapei.get_user.id, dapei.url)
        end
        if prev_level < 5 and current_level >= 5
          dapei.rand_like
          PushNotification.push_star_dapei(dapei.get_user.id, dapei.url)
        end
      end

      if dapei.category_id == 1001 or dapei.category_id == 1000
        if params[:start_date]
          dapei.dapei_info.start_date = params[:start_date]
        end
        if params[:end_date]
          dapei.dapei_info.end_date = params[:end_date]
        end

        if params[:start_date_hour]
          dapei.dapei_info.start_date_hour = params[:start_date_hour]
        end

        if params[:dapei_tags_id]
          dapei.dapei_info.dapei_tags_id = params[:dapei_tags_id].to_i
        end
      end
      dapei.dapei_info.save
    end
    if dapei.level && dapei.level >= 2
      FlashBuy::Api.add_coin(dapei, 'push_homepage')
    end
    dapei.save
    if level_before != level_now
      dapei.show_date = dapei.updated_at
    end
    dapei.save
    redirect_to :back
    #redirect_to [:manage,:dapeis]
  end

  def destroy
    dapei = Item.find_by_url params[:id]
    dapei.destroy
    render nothing: true
  end

  private
  def set_param_side
    @param_side = 'manage/dapeis/sidebar'
  end
end
