# -*- encoding : utf-8 -*-
#encoding: utf-8
class Manage::CrawlerTemplatesController < Manage::BaseController
  before_filter :set_param_side

  def index
    @q = CrawlerTemplate.includes([:brand,:mall]).ransack params[:q]
    @crawler_templates = @q.result.order('id desc').page(params[:page]).per(16)
  end

  def new
    @crawler_template = CrawlerTemplate.new
    render partial: 'form'
  end

  def create
    crawler_template = CrawlerTemplate.new params[:crawler_template]
    crawler_template.save
    redirect_to [:manage,:crawler_templates]
  end

  def edit
    @crawler_template = CrawlerTemplate.find params[:id]
    render partial: 'form'
  end

  def update
    @crawler_template = CrawlerTemplate.find params[:id]
    @crawler_template.update_attributes params[:crawler_template]
    redirect_to [:manage,:crawler_templates]
  end

  def search_brands
    @brands = Brand.select([:id,:name,:url]).where("lower(name) like '#{params[:query]}%'").order("id asc").limit(10).collect {|b| [b.name,b.id] }
  end

  def search_malls
    @malls = Mall.select([:id,:name]).where("lower(name) like '#{params[:query]}%'").order("id asc").limit(10).collect {|m| [m.name,m.id] }
  end


  private
  def set_param_side
    params[:side] = 'manage/brands/sidebar'
  end

end
