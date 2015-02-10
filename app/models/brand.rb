# -*- encoding : utf-8 -*-
class Brand < ActiveRecord::Base
  include Sjb::Likeable
  include Sjb::Commentable
  validates :name, :presence => true

  attr_accessible :name, :e_name, :display_name, :img_quality, :brand_type, :brand_type_1, :brand_type_2, :brand_type_3, :des, :skus, :price_level, :priority, :low_price, :high_price, :brand_intro, :shops, :photos, :url, :products, :level, :phone_number, :address, :weibo, :weixin, :homepage, :tmall, :crawled_source, :avatar_id, :wide_avatar_url, :shop_photo_id, :domain, :category_id, :white_avatar_url, :black_avatar_url, :campaign_img_url, :wide_banner_url, :currency
  has_many :skus, :dependent => :destroy
  has_many :tshows, :dependent => :destroy
  has_many :tshow_spiders, :dependent => :destroy
  has_many :shops
  has_many :photos, :as => :target #, :dependent=>:destroy
  has_many :crawler_templates
  has_many :spiders
  has_many :items
  has_many :matters
  belongs_to :category


  LEVEL = [
      ["负一", -1], ["零级", 0], ["一级", 1], ["二级", 2], ["三级", 3], ["四级", 4], ["五级", 5], ["V级", 10], ["V+级", 20]
  ]

  PRIORITY = [
      ["一级", 1], ["二级", 2], ["三级", 3], ["四级", 4], ["五级", 5],
      ["六级", 6], ["七级", 7], ["八级", 8], ["九级", 9], ["十级", 10]
  ]

  IMG_QUALITY = [
      ["一级", 1], ["二级", 2], ["三级", 3], ["四级", 4], ["五级", 5],
      ["六级", 6], ["七级", 7], ["八级", 8], ["九级", 9], ["十级", 10]
  ]

  acts_as_commentable
  acts_as_url :name #, :sync_url=>true

  scope :liked_by, lambda { |user|
    joins(:likes).where(:likes => {:user_id => user.id}).order("likes.created_at desc")
  }

  scope :commented_by, lambda { |user|
    joins(:comments).where(:comments => {:user_id => user.id})
  }

  scope :available, lambda {
    where("level>=4").order("shops_count DESC")
  }

  acts_as_api
  api_accessible :public, :cache => 180.minutes do |t|
    t.add lambda { |brand| brand.id.to_s }, :as => :brand_id
    t.add :get_display_name, :as => :name
    t.add :e_name
    t.add :url
    t.add :avatar_url
    t.add :get_wide_avatar_url, :as => :wide_avatar_url
    t.add :get_white_avatar_url, :as => :white_avatar_url
    t.add :get_black_avatar_url, :as => :black_avatar_url
    t.add lambda { |brand| brand.wide_campaign_img(:wide_half) }, :as => :wide_half_campaign_img
    t.add lambda { |brand| brand.wide_campaign_img(:wide_medium) }, :as => :wide_medium_campaign_img
    t.add lambda { |brand| brand.is_v }, :as => :is_v

    t.add lambda { |item| item.likes_count.to_s }, :as => :likes_count
    t.add lambda { |item| item.get_skus_count.to_s }, :as => :skus_count
    t.add :like_id_s, :as => :like_id
    t.add :new_skus_count
    t.add :brief
    #t.add :current_discount_title , :as => :discount_title
  end

  acts_as_api
  api_accessible :priv, :cache => 180.minutes do |t|
    t.add lambda { |brand| brand.id.to_s }, :as => :brand_id
    t.add :get_display_name, :as => :name
    t.add :e_name
    t.add :url
    t.add :get_low_price_s, :as => :low_price
    t.add :get_high_price_s, :as => :high_price
    t.add :brand_intro
    t.add :avatar_url
    t.add :get_wide_avatar_url, :as => :wide_avatar_url
    t.add :get_white_avatar_url, :as => :white_avatar_url
    t.add :get_black_avatar_url, :as => :black_avatar_url
    t.add :banner_url
    t.add :shop_photo_url
    t.add :brief

    t.add lambda { |brand| brand.wide_campaign_img(:wide_half) }, :as => :wide_half_campaign_img
    t.add lambda { |brand| brand.wide_campaign_img(:wide_medium) }, :as => :wide_medium_campaign_img
    t.add lambda { |brand| brand.is_v }, :as => :is_v

    t.add lambda { |item| item.comments_count.to_s }, :as => :comments_count
    t.add lambda { |item| item.get_likes_count.to_s }, :as => :likes_count
    t.add lambda { |item| item.get_dispose_count.to_s }, :as => :dispose_count
    t.add lambda { |item| item.get_skus_count.to_s }, :as => :skus_count
    t.add :new_skus_count
    t.add :like_id_s, :as => :like_id
    t.add lambda { |brand| brand.img_urls(:wide_medium) }, :as => :brand_imgs
    #t.add :lookbooks
    #t.add :campaigns
    t.add lambda { |brand| brand.wide_campaign_imgs(:wide_small) }, :as => :wide_campaign_imgs
  end

  scope :recommended, lambda {
    joins("INNER JOIN recommends ON recommends.recommended_id = brands.id").where("recommends.recommended_type = 'Brand' ").order("recommends.updated_at desc").limit(18)
  }

  ransacker :name do |parent|
    Arel::Nodes::NamedFunction.new('LOWER', [parent.table[:name]])
  end



  def get_items_by_brand
    @items = Item.tagged_with(self.display_name).where('level>=2 and deleted is null and dapei_info_flag is null').limit(3)
  end

  def self.api_get_all_brands
    # Rails.cache.fetch("brand_real_list", :expires_in => 12.hours) do
      Brand.where("dapei_count >= 3").order("dapei_count desc")
    # end
    #   @brands = Array.new
    #   Brand.where("level is not null and display_name is not null").find_each(batch_size: 500) do |brand|
    #     if Item.tagged_with(brand.display_name).where('level>=2 and deleted is null and dapei_info_flag is null').size >=3
    #       @brands <<brand
    #     end
    #   end
    #   @brands  
  end

  def get_items
    items = Array.new
    flag = 0
    self.skus.each  do |sku|
      sku.items.each do |item|
        if item.present?
          items<<item
        end
        if items.size==3
          flag = 1
          break
        end
      end
      if flag == 1
        break
      end
    end 
    items
  end
  def is_v
    return "1" if self.level.to_i >= 10
    return "0"
  end

  def get_avatar_url
    if self.avatar_url and self.avatar_url != "" and self.avatar_url != "/assets/0.gif"
      self.avatar_url
    else
      get_wide_avatar_url
    end
  end


  def get_wide_avatar_url
    if self.wide_avatar_url and self.wide_avatar_url != ""
      self.wide_avatar_url
    else
      "http://dpms.qiniudn.com/assets/img.png"
    end
  end

  def current_spider
    self.spiders.where { stop==false }.order { created_at.desc }.first
  end

  def recent_spider
    self.spiders.order { created_at.desc }.first
  end

  def get_white_avatar_url
    if self.white_avatar_url and self.white_avatar_url != ""
      self.white_avatar_url
    else
      "http://www.shangjieba.com/assets/img.png"
    end
  end

  def get_black_avatar_url
    if self.black_avatar_url and self.black_avatar_url != ""
      self.black_avatar_url
    else
      "http://www.shangjieba.com/assets/img.png"
    end
  end

  def category_skus
    category_count = self.matters.where { (created_at>1.week.ago)&(category_id<100) }.group { category_id }.count
    return category_count
  end

  def count_skus_by_category
    category_count = category_skus
    category_ids = category_count.keys
    category_name = Category.where { id>>category_ids }.inject({}) { |h, v| h[v.id] = v.name; h }
    category_ids.inject({}) { |h, v| h[category_name[v]] = category_count[v]; h }
  end

  def lookbooks
  end

  def campaigns
  end

  def w_campaigns
  end

  def h_campaigns
  end

  def wide_campaign_img(size)
    if self.campaign_img_url
      self.campaign_img_url
    else
      get_pod_url+"/assets/img.jpg"
    end
  end

  def wide_campaign_imgs(size)
    imgs = []
    imgs
  end

  def high_campaign_img(size)
    get_pod_url+"/assets/img.jpg"
  end

  def has_liked?
    if User.current_user and Like.has_liked?(User.current_user.id, self.id, "Brand")
      return true
    else
      return false
    end
  end

  def get_display_name
    if self.display_name and self.display_name != ""
      self.display_name
    else
      self.get_name
    end
  end

  def brand_name
    self.get_display_name
  end

  def like_id
    like=Like.find_by_user_id_and_target_id_and_target_type(User.current_user.id, self.id, "Brand")
    like.id
  end

  def is_like(user)
    return 0 if not user
    like=Like.find_by_user_id_and_target_id_and_target_type(user.id, self.id, "Brand")
    if like
      like_id=like.id.to_s
    else
      0
    end
  end

  def like_id_s
    like_id="0"
    if has_liked?
      like=Like.find_by_user_id_and_target_id_and_target_type(User.current_user.id, self.id, "Brand")
      like_id=like.id.to_s
    end
    like_id
  end


  def new_skus_count
    self.matters.where("level >= ?", self.level).where("created_at > ?", Time.now.midnight - 7.days).count.to_s
  end

  def spiders_count
    self.matters.where("level >= ?", self.level).where("level >= ?", 5).where("created_at > ?", Time.now.midnight - 1.days).count
  end

  def seasonal_skus_count
    self.matters.where("matters.category_id < 100").where("created_at > ?", Time.now.midnight - 90.days).count
  end

  def get_skus_count(cid=nil)
    where = "1=1"
    if cid != nil
      where = "cid=#{cid}"
      self.skus.where("level >= ?", self.level).where("#{where}").count.to_s
    else
      self.skus_count
    end

  end

  def get_likes_count
    self.likes_count.to_i * 10 + rand(10)
  end


  def get_low_price
    low_price=-1
    if self.low_price
      low_price=self.low_price
    end
    low_price
  end

  def get_low_price_s
    low_price=-1
    if self.low_price
      low_price=self.low_price
    end
    low_price.to_s
  end

  def get_high_price
    high_price=-1
    if self.high_price
      high_price=self.high_price
    end
    high_price
  end

  def get_high_price_s
    high_price=-1
    if self.high_price
      high_price=self.high_price
    end
    high_price.to_s
  end

  def avatar
    if self.avatar_id
      Photo.find_by_id(self.avatar_id)
    end
  end

  def shop_name
    self.name
  end

  def get_name
    if self.e_name and self.e_name != ""
      self.e_name
    elsif self.c_name and self.c_name != ""
      self.c_name
    else
      self.name
    end
  end

  def avatar_url
    if profile_image and profile_image != ""
      profile_image
    else
      wide_avatar_url
    end
  end

  def profile_image
    if self.avatar
      self.avatar.url(:thumb_medium)
    else
      ""
    end
  end

  def shop_photo
    if self.shop_photo_id
      Photo.find_by_id(self.shop_photo_id)
    end
  end

  def shop_photo_url
    if self.shop_photo_id
      photo = Photo.find_by_id(self.shop_photo_id)
      if photo
        return photo.url(:wide_medium)
      end
    end
    "/assets/img.jpg"
  end

  def shop_img_url(size)
    if self.shop_photo_id
      photo = Photo.find_by_id(self.shop_photo_id)
      if photo
        return photo.url(size)
      end
    end
    "/assets/img.jpg"
  end

  def img_urls(size)
    img_urls=Array.new
    default_url=get_pod_url+"/assets/img.jpg"
    temp={:img_url => default_url, :width => "300", :height => "300"}
    if self.photos and self.photos.length>0
      self.photos.each do |photo|
        temp = {}
        if size == :api_big
          temp[:img_url]=photo.url(:scaled_full)
          temp[:img_url] = temp[:img_url].gsub("img.shangjieba", "www.shangjieba")
        else
          temp[:img_url]=photo.url(size)
        end
        temp[:width]=photo.width
        temp[:height]=photo.height
        img_urls<<temp
      end
    else
      img_urls<<temp
    end
    img_urls
  end

  def banner_url
    #should be changed later
    if self.wide_banner_url
      self.wide_banner_url
    else
      img_url=get_pod_url+"/assets/img.jpg"
      if self.photos and self.photos.length>0
        self.photos.sort_by { |photo| photo.created_at }
        photo=self.photos.last
        img_url=photo.url(size)
      end
      img_url
    end
  end


  def incr_dispose
    key = "brand_#{self.url}"
    $redis.incr(key)
  end

  def get_dispose_count
    begin
      if $redis.get("brand_#{self.url}")
        return $redis.get("brand_#{self.url}")
      else
        self.dispose_count
      end
      rescue => e
      self.dispose_count
    end
  end

  def get_brand_shops
    @page = "1"
    searcher = Searcher.new(@city_id, "shop", "", "hot", 10, @page, nil, nil, nil, nil, self.id)
    @shops = searcher.search()
  end

  def sync_shops_count
    self.shops.where('shops.level >=?', 0).length
  end

  def by_name(name)
    brand = Brand.find_by_e_name(name.downcase)
    if not brand
      brand = Brand.find_by_c_name(name.downcase)
    end
    if not brand
      brand = Brand.find_by_name(name)
    end
    brand
  end

  def get_spider_path
    if self.spiders.length > 0
      return "/brand_admin/spiders/#{self.spiders.first.id}/edit"
    elsif self.crawler_templates.length > 0
      return "/brand_admin/crawler_templates/#{self.crawler_templates.first.id}/edit"
    else
      return "#"
    end
  end


  def get_active_spider
    if self.spiders.length > 0
      return self.spiders.last
    end
  end

  def get_spider_crop
    if self.get_active_spider
      self.get_active_spider.crop.to_s
    else
      ""
    end
  end


  def get_spider_domain
    if self.get_active_spider
      self.get_active_spider.spider_domain
    else
      ""
    end
  end


  def sync_shop
    self.skus.each do |sku|
      sku.level_sku
      p sku.level
    end
    b= self
    b.shops.each do |s|
      #s.sync_all_sku
      #s.sync_brand_sku(10)
      if s.level.to_i >= 0 and (s.level.to_i != b.level.to_i or s.priority.to_i != b.priority.to_i)
        s.level = b.level
        s.priority = b.priority
        p s.city_id, s.level, s.name, s.priority
        s.save
      end
    end
  end

  def city(city_id)
    brands = []
    s = Searcher.new(city_id, "shop", "")
    s.getBrandGroup
    num = 0
    s.get_bg.each do |d|
      num += 1
      break if num >= 30
      brands << d['brand_id'] if d['brand_id'].to_i > 0
    end
    return Brand.where(:id => brands).limit(30)
  end


  def get_dispose_count
    if $redis.get("brand_#{self.id}")
      $redis.get("brand_#{self.id}")
    else
      self.dispose_count
    end
  end

  def get_tags
    tags = []
    ['brand_type', 'brand_type_1', 'brand_type_2', 'brand_type_3'].each do |bt|
      btag = BrandTag.find_by_id(eval "self.#{bt}")
      name = ""
      name = btag.name if btag
      tags << name
    end
    tags.join("|")
  end

  def get_describe
    [self.e_name.to_s, self.c_name.to_s, self.display_name].uniq.join('|')
  end


  def incr_dispose
    key = "brand_#{self.id}"
    $redis.incr(key)
  end

  def top_hot_skus
    self.skus.where("level>=#{self.level.to_i}").order("updated_at desc").limit(8)
  end

  def is_match_shop(shop_name)
    s = shop_name.gsub(/[\(（].*[\)）]/, "").downcase
    s = s.gsub(/鞋店/, '')
    e_name = s.gsub /[^\w]/, ''
    c_name = s.gsub /[^\u4e00-\u9fa5]/, ''
    print e_name, "vs", self.e_name, "\n"
    print c_name, "vs", self.c_name, "\n"
    return e_name == self.e_name if c_name == ""
    return c_name == self.c_name if e_name == ""
    return (e_name + c_name == self.e_name + self.c_name)
  end


  def brief
    desc = ""
    if self.brand_type_3 and bt = BrandTag.find_by_id(self.brand_type_3)
      desc += bt.name
    end
    #if self.brand_type_2 and bt = BrandTag.find_by_id(self.brand_type_2)
    #  desc += bt.name
    #end
    if self.brand_type and bt = BrandTag.find_by_id(self.brand_type)
      desc += bt.name
    end
    if self.brand_type_1 and bt = BrandTag.find_by_id(self.brand_type_1)
      desc += bt.name
    end

    desc
  end


  def brief_html
    desc = ""
    if self.brand_type_3 and bt = BrandTag.find_by_id(self.brand_type_3)
      desc += "<a href='/manage/brands?tid=#{brand_type_3}'>#{bt.name}</a><br/>"
    end
    #if self.brand_type_2 and bt = BrandTag.find_by_id(self.brand_type_2)
    #  desc += bt.name
    #end
    if self.brand_type and bt = BrandTag.find_by_id(self.brand_type)
      desc += "<a href='/manage/brands?tid=#{brand_type}'>#{bt.name}</a><br/>"
    end
    if self.brand_type_1 and bt = BrandTag.find_by_id(self.brand_type_1)
      desc += "<a href='/manage/brands?tid=#{brand_type_1}'>#{bt.name}</a>"
    end

    desc
  end

  def get_likers
    return self.likes.map(&:user)
  end

  def get_dapeis(limit=8, page=1)
    searcher = Searcher.new("dapei", self.name, "new", limit, page)
    @dapeis = searcher.search()
  end

  def self.cache_brands_level_bigger_than(level)
    Rails.cache.fetch "brands/level/bigger/#{level}", :expires_in => 3.minutes do
      Brand.where("level >= #{level}").order("updated_at desc").entries
    end
  end

  def matters_count
    Matter.where("brand_id = #{self.id}").length
  end

  # api 所有品牌
  def self.api_get_brands
    # Rails.cache.fetch("get_brands", :expires_in => 300.minutes) do
      # all_brands = $redis.lrange('all_brands', 0, -1)
      # if all_brands.blank?
      #   $redis.lpush('all_brands', Brand.pluck(:display_name))
      #   all_brands = $redis.lrange('all_brands', 0, -1)
      # end
      # all_brands.delete("")
      # all_brands.compact.uniq.sort
      all_brands = Brand.where("display_name is not null").pluck(:display_name)
      all_brands.delete("")
      all_brands
    # end
  end

  

  after_save :update_api_get_brands

  def update_api_get_brands
    $redis.rpush('all_brands', self.display_name)
  end

  private
  def get_pod_url
    pod_url = AppConfig[:pod_url].dup
    pod_url.chop! if AppConfig[:pod_url][-1, 1] == '/'
    pod_url
  end

end
