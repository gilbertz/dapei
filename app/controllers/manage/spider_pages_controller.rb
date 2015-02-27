# -*- encoding : utf-8 -*-
class Manage::SpiderPagesController < Manage::BaseController
  before_filter :get_categories_for_select, :only => [:new, :edit]


  def index
  end

  def new
    @spider = Spider.find params[:spider_id] 
    @spider_page = SpiderPages.new(:spider_id => @spider.id)
    render partial: 'form'
  end

  def create
    @spider = Spider.find params[:spider_id]
    
    @spider_page = SpiderPages.new(params[:spider_pages].merge(:spider_id => @spider.id))
    @spider_page.save
    redirect_to [:edit, :manage, @spider]
  end

  def edit
    @spider = Spider.find params[:spider_id]
    @spider_page = SpiderPages.find params[:id]
    render partial: 'form'
  end

  def update
    spider = Spider.find params[:spider_id]
    spider_page = SpiderPages.find params[:id]
    spider_page.update_attributes params[:spider_pages]
    redirect_to [:edit, :manage, spider]
  end

  def destroy
    @spider = Spider.find params[:spider_id]

    spider_page = SpiderPages.find params[:id]
    spider_page.destroy
    redirect_to [:edit, :manage, @spider]
    #render nothing: true
  end

private
  def get_categories_for_select
    @categories_for_select = Category.select([:name,:id]).collect do|rc|
      [rc.name, rc.id]
    end
  end

end
