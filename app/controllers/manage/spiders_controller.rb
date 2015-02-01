# -*- encoding : utf-8 -*-
#encoding: utf-8
class Manage::SpidersController < Manage::BaseController
  before_filter :set_param_side
  before_filter :load_templates, only: [:new,:edit]

  def index
    cond = "1=1"
    cond = "template_id=#{params[:tid]}" if params[:tid]
    cond = "brand_id=#{params[:bid]}" if params[:bid]

    query_str = params[:q].nil? ? nil : params[:q].to_downcase
    @q = Spider.where(cond).includes(:brand).ransack query_str
    @spiders = @q.result.order('stop asc').page(params[:page]).per(20)
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
    #params[:spider][:size_types] = params[:spider][:size_types].reject{|size_type| size_type.strip.empty?}.join(",")
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
    #spider_id = params[:id]
    #brand_id = Spider.find(spider_id).brand_id
    #prior_crawl_queue = $redis_crawler.lrange("prior_crawl_queue",0,-1)
    #$redis_crawler.rpush("prior_crawl_queue", spider_id ) unless prior_crawl_queue.include?(spider_id)
    #`cd /var/www/crawler/ && /bin/bash ./spider_crawler.sh #{spider_id} #{brand_id} > spider_crawler_#{spider_id}.log`
    
    sp  = Spider.find params[:id]
    t = Thread.new do
      sp.crawler_command
    end
    t.join
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

  def load_templates
    @templates = Spider.includes(:brand).where(is_template: true).collect do |t| 
      [t.brand.try(:name),t.id] 
    end
  end
end
