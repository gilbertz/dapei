# -*- encoding : utf-8 -*-
#encoding: utf-8
class Manage::ShopsController < Manage::BaseController

  def index
    @cities = Area.online_cities.collect {|c| [c.name, c.city_id] }
    @q = Shop.includes(:brand).where(shop_type: 11).ransack params[:q]
    @shops = @q.result.page(params[:page]).per(10)
  end

  def discounts
    @shop = Shop.find_by_url params[:id]
    @q = @shop.discounts.ransack(params[:q]) 
    @discounts = @q.result.page(params[:page]).per(10)  
  end

  def show
    @shop = Shop.find_by_url params[:id]
    @q = @shop.items.includes(sku: :photos).ransack(params[:q]) 
    @items = @q.result.page(params[:page]).per(10)  
  end

  def edit
    @shop = Shop.find_by_url params[:id]
    @brands = Brand.select([:id,:name,:url]).order("url asc").collect do |b| [b.name, b.id] end
    @cities = Area.online_cities.collect {|c| [c.name, c.city_id] }
    @areas = Area.dist(1).collect {|a| [a.name,a.id] }
    @malls = Mall.select([:id,:name,:url]).where(:city_id => @city_id) 
    .order("url asc").collect {|m| [m.name, m.id] }
  end

  def destroy
    @shop = Shop.find_by_url params[:id]
    render nothing: true
  end
end
