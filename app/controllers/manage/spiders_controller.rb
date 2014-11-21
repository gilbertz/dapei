# -*- encoding : utf-8 -*-
#encoding: utf-8
class Manage::SpidersController < Manage::BaseController
  before_filter :set_param_side
  before_filter :load_templates, only: [:new,:edit]
  before_filter :load_cosmetic_house_subcats, only: [:new,:edit]

  def index
    cond = "1=1"
    cond = "template_id=#{params[:tid]}" if params[:tid]
    cond = "brand_id=#{params[:bid]}" if params[:bid]

    query_str = params[:q].nil? ? nil : params[:q].to_downcase
    @q = Spider.where(cond).includes(:brand).ransack query_str
    @spiders = @q.result.order('id desc').page(params[:page]).per(20)
  end

  def new
    @size_types = SizeType.all
    @brand = Brand.find params[:brand_id]
    @spider = @brand.spiders.new
  end

  def create
    params[:spider][:size_types] = params[:spider][:size_types].reject{|size_type| size_type.strip.empty?}.join(",")
    spider = Spider.new params[:spider]
    spider.save
    redirect_to [:spiders,:manage,spider.brand]
  end

  def edit
    @size_types = SizeType.all
    @spider = Spider.find params[:id]
    @size_types_str = @spider.size_types 
  end

  def update
    spider = Spider.find params[:id]
    params[:spider][:size_types] = params[:spider][:size_types].reject{|size_type| size_type.strip.empty?}.join(",")
    spider.update_attributes params[:spider]
    redirect_to spiders_manage_brand_path(spider.brand)
  end

  def update_state
    spider = Spider.find params[:id]
    spider.invert_state
    #render json: {msg: 'ok', val: spider.stop}
    redirect_to :back
  end

  
  def destroy
    spider = Spider.find params[:id]
    spider.destroy
    render nothing: true
  end

  def start_crawl
    spider_id = params[:id]
    brand_id = Spider.find(spider_id).brand_id
    prior_crawl_queue = $redis_crawler.lrange("prior_crawl_queue",0,-1)
    $redis_crawler.rpush("prior_crawl_queue", spider_id ) unless prior_crawl_queue.include?(spider_id)
    `cd /var/www/crawler/ && /bin/bash ./spider_crawler.sh #{spider_id} #{brand_id} > spider_crawler_#{spider_id}.log`
    render nothing: true
  end

  def start_soldout
    spider_id = params[:id]
    brand_id = Spider.find(spider_id).brand_id
    `cd /var/www/soldout/ && /bin/bash ./spider_soldout.sh #{spider_id} #{brand_id} > spider_soldout_#{spider_id}.log`
    render nothing: true
  end

  private
  def set_param_side
    params[:side] = 'manage/brands/sidebar'
  end

  def load_cosmetic_house_subcats
    @cosmetic_sub_cats = Category.where{parent_id==9}.collect do |sub_cat| 
      [sub_cat.try(:name),sub_cat.id] 
    end
    @cosmetic_sub_cats = [ ["无", 0] ] + @cosmetic_sub_cats
    @house_sub_cats = Category.where{parent_id==10}.collect do |sub_cat| 
      [sub_cat.try(:name),sub_cat.id] 
    end
    @house_sub_cats = [ ["无", 0] ] + @house_sub_cats
    @tops_sub_cats = Category.where{parent_id==11}.collect do |sub_cat| 
      [sub_cat.try(:name),sub_cat.id] 
    end
    @tops_sub_cats = [ ["无", 0] ] + @tops_sub_cats
    @shoes_sub_cats = Category.where{parent_id==4}.collect do |sub_cat| 
      [sub_cat.try(:name),sub_cat.id] 
    end
    @shoes_sub_cats = [ ["无", 0] ] + @shoes_sub_cats
    @bags_sub_cats = Category.where{parent_id==5}.collect do |sub_cat| 
      [sub_cat.try(:name),sub_cat.id] 
    end
    @bags_sub_cats = [ ["无", 0] ] + @bags_sub_cats
    @accs_sub_cats = Category.where{parent_id==6}.collect do |sub_cat| 
      [sub_cat.try(:name),sub_cat.id] 
    end
    @accs_sub_cats = [ ["无", 0] ] + @accs_sub_cats
    @pants_sub_cats = Category.where{parent_id==12}.collect do |sub_cat| 
      [sub_cat.try(:name),sub_cat.id] 
    end
    @pants_sub_cats = [ ["无", 0] ] + @pants_sub_cats
    @skirts_sub_cats = Category.where{parent_id==13}.collect do |sub_cat| 
      [sub_cat.try(:name),sub_cat.id] 
    end
    @skirts_sub_cats = [ ["无", 0] ] + @skirts_sub_cats
  end

  def load_templates
    @templates = Spider.includes(:brand).where(is_template: true).collect do |t| 
      [t.brand.try(:name),t.id] 
    end
  end
end
