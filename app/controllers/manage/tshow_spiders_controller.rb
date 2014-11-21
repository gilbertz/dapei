# -*- encoding : utf-8 -*-
class Manage::TshowSpidersController < Manage::BaseController
  before_filter :set_param_side
  before_filter :load_templates, only: [:new,:edit]

  def index
    cond = "1=1"
    cond = "template_id=#{params[:tid]}" if params[:tid]

    query_str = params[:q].nil? ? nil : params[:q].to_downcase
    @q = TshowSpider.where(cond).includes(:brand).ransack query_str
    @tshow_spiders = @q.result.order('id desc').page(params[:page]).per(20)
  end

  def new
    @brand = Brand.find params[:brand_id]
    @tshow_spider = @brand.tshow_spiders.new
  end

  def create
    tshow_spider = TshowSpider.new params[:tshow_spider]
    tshow_spider.save
    redirect_to [:spiders,:manage,tshow_spider.brand]
  end

  def edit
    @tshow_spider = TshowSpider.find params[:id]
  end

  def update
    tshow_spider = TshowSpider.find params[:id]
    tshow_spider.update_attributes params[:tshow_spider]
    redirect_to spiders_manage_brand_path(tshow_spider.brand)
  end
  
  def destroy
    tshow_spider = TshowSpider.find params[:id]
    tshow_spider.destroy
    render nothing: true
  end

  def start_crawl
    spider_id = params[:id]
    brand_id = TshowSpider.find(spider_id).brand_id
    `cd /var/www/crawler/ && /bin/bash ./tshow_spider_crawler.sh #{spider_id} #{brand_id} > tshow_spider_crawler_#{spider_id}.log`
    render nothing: true
  end

  private
  def set_param_side
    params[:side] = 'manage/brands/sidebar'
  end

  def load_templates
    @templates = TshowSpider.includes(:brand).where(is_template: true).collect do |t| 
      [t.brand.try(:name),t.id] 
    end
  end
end
