# -*- encoding : utf-8 -*-
#encoding: utf-8
class Manage::BrandsController < Manage::BaseController
  before_filter :get_tags, only: [:new,:edit]

  def index
    cond = "1=1"
    params[:priority] && cond += " and priority = #{params[:priority]}"
    params[:level] && cond += " and level = #{params[:level]}"
    if params[:tid]
      tid = params[:tid]
      bt = BrandTag.find_by_id(tid)
      if bt
        cond += " and brand_type = #{tid}"  if bt.type_id == 1
        cond += " and brand_type_1 = #{tid}"  if bt.type_id == 2
        cond += " and brand_type_2 = #{tid}"  if bt.type_id == 3
        cond += " and brand_type_3  ,m= #{tid}"  if bt.type_id == 4
      end
    end
    order = 'id desc' 
    params[:order] && params[:order] == 'hot' && order = 'updated_at desc'

    query_str = params[:q].nil? ? nil : params[:q].to_downcase
    @q = Brand.where(cond).ransack query_str
    @brands = @q.result.order(order).page(params[:page]).per(20)
  end

  def spiders
    @brand = Brand.find params[:id]
    @q = @brand.spiders.ransack params[:q]
    @spiders = @q.result
    @tshow_spider_q = @brand.tshow_spiders.ransack params[:q]
    @tshow_spiders = @tshow_spider_q.result
  end

  def new
    @brand = Brand.new
  end

  def create
    @brand = Brand.new(params[:brand])
    @brand.save
    redirect_to manage_brands_path
  end

  def edit
    @brand = Brand.find params[:id]
  end

  def update
    @brand = Brand.find params[:id]
    @brand.update_attributes params[:brand]
    redirect_to [:manage,:brands]
  end

  def destroy
    brand = Brand.find params[:id]
    brand.spiders.destroy_all
    brand.skus.destroy_all
    brand.destroy
    render nothing: true
  end

  def upload
    require 'fileutils' #ruby老版本可尝试改为 require 'ftools'

    dir = ""
    tmp = nil
    field = nil

    brand_id = params[:id]
    brand = Brand.find_by_id(brand_id)

    salt = rand(100)

    if params[:logo_file].present?
      tmp = params[:logo_file]
      dir = "logo"
      brand.wide_avatar_url = "http://dpms.qiniudn.com/uploads/#{dir}/#{brand.id}#{salt}.png"
    elsif params[:logo_white_file].present?
      dir = "logo_white"
      brand.white_avatar_url = "http://dpms.qiniudn.com/uploads/#{dir}/#{brand.id}#{salt}.png"
      tmp = params[:logo_white_file]
    elsif params[:logo_black_file].present?
      dir = "logo_black"
      brand.black_avatar_url = "http://dpms.qiniudn.com/uploads/#{dir}/#{brand.id}#{salt}.png"
      tmp = params[:logo_black_file]
    elsif params[:wide_banner_file].present?
      dir = "wide_banner"
      brand.wide_banner_url = "http://dpms.qiniudn.com/uploads/#{dir}/#{brand.id}#{salt}.png"
      tmp = params[:wide_banner_file]
    elsif params[:wide_avatar_file].present?
      dir = "wide_avatar"
      brand.wide_avatar_url = "http://dpms.qiniudn.com/uploads/#{dir}/#{brand.id}#{salt}.png"
      tmp = params[:wide_avatar_file]
    elsif params[:wide_campaign_img]
      dir = "campaign"
      brand.campaign_img_url = AppConfig[:remote_image_domain] + "/uploads/#{dir}/#{brand.id}#{salt}.png"
      tmp = params[:wide_campaign_img]
    end

    dir_path = "#{Rails.root}/public/uploads/#{dir}"
    FileUtils.mkdir_p(dir_path) unless Dir.exist?(dir_path)

    file = File.join(dir_path, "#{brand_id}#{salt}.png")

    File.open(file, "wb") { |f| f.write( tmp.read() ) }
    if brand
      brand.save
    end

    render json: {"image_url" => "http://dpms.qiniudn.com/uploads/#{dir}/#{brand.id}#{salt}.png"}
  end
  
  private
  def get_tags
    @tags = BrandTag.where{type_id.in([1,2,3,4])}.to_a
  end
end
