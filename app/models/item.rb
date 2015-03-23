# -*- encoding : utf-8 -*-

class Item < ActiveRecord::Base
  include Sjb::Likeable
  include Sjb::Commentable
  acts_as_taggable_on :tags
  acts_as_taggable_on :btags
  acts_as_taggable_on :ctags
  acts_as_taggable_on :mtags

  validates :title, :presence => true
  #validates :category_id, :presence=>true
  attr_accessible :title, :price, :discount, :display_area, :shop_id, :category_id, :discounts, \
    :photos, :sku_id, :deleted, :from, :origin_price, :off_percent, :tags, :desc, :user_id, :suid, :level, :type, :index_info, :dapei_info_flag
  attr_accessor :distance, :get_dispose_count

  has_one :dapei_info, foreign_key: 'dapei_id'
  #belongs_to :shop, :inverse_of => :items, :counter_cache => true
  #belongs_to :sku, :inverse_of => :items, :counter_cache => true
  belongs_to :meta_tag

  belongs_to :user #, :counter_cache=>true
  belongs_to :category #, :counter_cache=>true
  has_many :photos, :as => :target #, :dependent=>:destroy
  has_many :rel_items
  has_many :relations
  belongs_to :brand
  has_one :relation, :class_name => "Relation"
  # has_one :relation_sku , :class_name => 'Sku',:through => :relation,:source => :target ,:source_type =>  'Sku'
  #has_many :relation_skus, :class_name => 'Sku', :through => :relations, :source_type => "Sku", :source => :target

  has_many :likes ,:as => :target
  acts_as_commentable
  #acts_as_url :title#, :sync_url=>true

  acts_as_api
  api_accessible :public, :cache => 180.minutes do |t|
    t.add :get_url, :as => :item_id
    t.add :show_title, :as => :title
    t.add :get_show_price, :as => :price
    t.add :get_origin_price, :as => :origin_price
    t.add :get_currency, :as => :currency
    #t.add :off_percent.to_s, :as => :off_percent
    t.add :shop_url, :as => :shop_id
    t.add :shop_name
    t.add :shop_display_name
    t.add :shop_street, :as => :street
    t.add :shop_address
    t.add :phone_number
    t.add :brand_name
    t.add :brand_id
    t.add :shop_avatar_url
    t.add :wide_avatar_url
    t.add :white_avatar_url
    t.add :black_avatar_url
    t.add lambda { |item| item.comments_count.to_i.to_s }, :as => :comments_count
    t.add lambda { |item| item.likes_count.to_i.to_s }, :as => :likes_count
    t.add lambda { |item| item.get_dispose_count.to_i.to_s }, :as => :dispose_count
    #t.add :category
    t.add lambda { |item| item.img_url(:thumb_small) }, :as => :img_sqr_small
    #t.add lambda{|item| item.img_url(:thumb_medium)}, :as => :img_sqr_medium
    t.add lambda { |item| item.img_url(:thumb_large) }, :as => :img_sqr_medium
    t.add lambda { |item| item.img_url(:normal_small) }, :as => :img_normal_small
    t.add lambda { |item| item.img_url(:normal_medium) }, :as => :img_normal_medium
    t.add lambda { |item| item.img_url(:scaled_large) }, :as => :img_scaled_large
    #t.add lambda{|item| item.img_urls(:thumb_medium)}, :as=> :img_urls_medium
    #t.add lambda{|item| item.img_urls(:scaled_full)}, :as=> :img_urls_large
    t.add lambda { |item| item.img_urls(nil) }, :as => :img_urls_large
    t.add :get_desc, :as => :desc
    t.add :like_id_s, :as => :like_id
    t.add lambda { |item| item.created_at.to_s }, :as => :created_at
    t.add lambda { |item| item.updated_at.to_s }, :as => :updated_at
    t.add lambda { |item| item.distance.to_s }, :as => :distance
    t.add :share_url
    t.add :share_img
    t.add :get_buy_status, :as => :buy_status
    t.add :get_buy_url, :as => :buy_url
    t.add :get_buy_domain, :as => :buy_domain
    t.add :get_img_width, :as => :width
    t.add :get_img_height, :as => :height
    t.add :get_scaled_img_width, :as => :scaled_img_width
    t.add :get_scaled_img_height, :as => :scaled_img_height
    t.add :get_dispose_count

  end


  #use for dapei detail
  acts_as_api
  api_accessible :dapei_detail do |t|
    t.add :url, :as => :dapei_id
    t.add :show_title, :as => :title
    t.add lambda { |item| item.comments_count.to_s }, :as => :comments_count
    t.add lambda { |item| item.incr_and_get_dispose_count.to_s }, :as => :dispose_count
    t.add lambda { |item| item.likes_count.to_s }, :as => :likes_count
    t.add lambda { |item| item.get_dpimg_urls() }, :as => :img_urls_large
    t.add lambda { |item| item.get_user_name }, :as => :posted_by
    t.add lambda { |item| item.dapei_img_url }, :as => :dapei_img_url
    t.add lambda { |item| item.get_editor_desc.to_s }, :as => :desc
    t.add lambda { |item| item.meta_tag }, :as => :meta_tag
    t.add :like_id_s, :as => :like_id
    t.add :created_at
    t.add :updated_at
    t.add :get_items, :as => :dapei_items, :template => :public
    t.add :get_items_count, :as => :dapei_items_count
    t.add :share_url
    t.add :share_img
    t.add :share_title
    t.add :share_desc
    t.add :get_user, :as => :user, :template => :light
    t.add :like_users, :template => :fast
    t.add :level
  end

  #use for dapei list
  acts_as_api
  api_accessible :dapei_list do |t|
    t.add :url, :as => :dapei_id
    t.add :type, :as => :type
    t.add :show_title, :as => :title
    t.add lambda { |item| item.comments_count.to_s }, :as => :comments_count
    t.add lambda { |item| item.likes_count.to_s }, :as => :likes_count
    t.add lambda { |item| item.incr_and_get_dispose_count.to_s }, :as => :dispose_count
    t.add lambda { |item| item.get_dpimg_urls() }, :as => :img_urls_large
    t.add lambda { |item| item.dapei_img_url }, :as => :dapei_img_url
    t.add lambda { |item| item.get_editor_desc.to_s }, :as => :desc
    t.add lambda { |item| item.meta_tag }, :as => :meta_tag
    t.add :like_id_s, :as => :like_id
    #t.add :created_at
    t.add :updated_at, :as => :created_at
    t.add :updated_at
    t.add :share_url
    t.add :share_img
    t.add :share_title
    t.add :share_desc
    t.add :get_items_count, :as => :dapei_items_count
    #t.add :desc
    t.add :get_user, :as => :user, :template => :light
    t.add :like_users, :template => :fast
  end

  acts_as_api
  api_accessible :dapei_response_list do |t|
    t.add :url, :as => :dapei_id
    t.add :title
    t.add lambda { |item| item.comments_count.to_s }, :as => :comments_count
    t.add lambda { |item| item.likes_count.to_s }, :as => :likes_count
    t.add lambda { |item| item.incr_and_get_dispose_count.to_s }, :as => :dispose_count
    t.add lambda { |item| item.get_dpimg_urls() }, :as => :img_urls_large
    t.add lambda { |item| item.dapei_img_url }, :as => :dapei_img_url
    t.add lambda { |item| item.get_editor_desc.to_s }, :as => :desc
    t.add lambda { |item| item.meta_tag }, :as => :meta_tag
    t.add :like_id_s, :as => :like_id
    t.add :created_at
    t.add :updated_at
    #t.add :share_url
    #t.add :share_img
    #t.add :share_title
    #t.add :share_desc
    t.add :get_items_count, :as => :dapei_items_count
    #t.add :desc
    t.add :get_user, :as => :user, :template => :light
    t.add :like_users, :template => :fast
  end


  def like_users
    Like.like_users(self, 1, 7)
    #self.likes.order('created_at desc').limit(8).map(&:user) 
  end

  def collection_like_users
    Like.like_users(self, 1, 8)
    #self.likes.order('created_at desc').limit(8).map(&:user) 
  end


  before_validation :auto_url

  def auto_url
    if self.url.blank?
      self.url=Devise.friendly_token[0, 20]+Item.maximum('id').to_s
    end
  end

  def get_dapei_img_url
    if self.category_id == 1002
      url=self.selfie_small_picture
    else
      url=self.dapei_img_url
    end
    if url.blank?
       url="http://1251008728.cdn.myqcloud.com/1251008728/zjl/baotu.jpg"
    end
    url
  end

  after_create :send_notifications

  api_accessible :error do |t|
    t.add :errors
  end

  scope :liked_by, lambda { |user|
    joins(:likes).where("items.category_id<100").where("items.level>=4").where(:likes => {:user_id => user.id}).order("likes.created_at desc")
  }

  scope :dapei_liked_by, lambda { |user|
    joins(:likes).where("items.category_id=1001 and deleted is null").where(:likes => {:user_id => user.id}).order("likes.created_at desc")
  }

  scope :collection_liked_by, lambda { |user|
    joins(:likes).where("items.category_id=1000 and deleted is null").where(:likes => {:user_id => user.id}).order("likes.created_at desc")
  }


  scope :dapeis_by, lambda { |user|
    joins("INNER JOIN dapei_infos ON dapei_infos.dapei_id = items.id").where("items.category_id=1001 and items.deleted is null").where(:user_id => user.id).order("items.created_at desc")
  }

  scope :fake_by, lambda { |user|
    joins("INNER JOIN dapei_infos ON dapei_infos.dapei_id = items.id").where("items.level is null or items.level<2").where("items.category_id=1001").order("items.created_at desc")
  }

  scope :v_dapeis_by, lambda { |user|
    where("items.level >= 2").where("items.category_id=1001 and deleted is null").where(:user_id => user.id).order("items.created_at desc")
  }

  scope :star_dapeis_by, lambda { |user|
    where("items.level >= 5").where("items.category_id=1001 and deleted is null").where(:user_id => user.id).order("items.created_at desc")
  }


  scope :commented_by, lambda { |user|
    joins(:comments).where(:comments => {:user_id => user.id})
  }

  scope :recommended, lambda { |cat_id, city_id|
    unless cat_id ==1
      joins("INNER JOIN recommends ON recommends.recommended_id = items.id").joins("INNER JOIN skus ON skus.id = items.sku_id").joins("INNER JOIN shops ON shops.id = items.shop_id").where("recommends.recommended_type = 'Item' and skus.category_id=#{cat_id}").where("shops.city_id=#{city_id}").order("recommends.created_at desc").limit(10)
    else
      joins("INNER JOIN recommends ON recommends.recommended_id = items.id").joins("INNER JOIN shops ON shops.id = items.shop_id").where('recommends.recommended_type = "Item" ').where("shops.city_id=#{city_id}").order("recommends.created_at desc").limit(10)
    end
  }


  scope :recommended_all, lambda { |cat_id|
    unless cat_id ==1
      joins("INNER JOIN recommends ON recommends.recommended_id = items.id").where("recommends.recommended_type = 'Item' and items.category_id=#{cat_id}").order("recommends.updated_at desc").limit(10)
    else
      joins("INNER JOIN recommends ON recommends.recommended_id = items.id").where('recommends.recommended_type' => "Item").order("recommends.updated_at desc").limit(10)
    end
  }


  scope :recommended2, lambda { |cat_id1, cat_id2|
    joins("INNER JOIN recommends ON recommends.recommended_id = items.id").where("recommends.recommended_type = 'Item' and (items.category_id=#{cat_id1} or items.category_id=#{cat_id2})").order("recommends.updated_at desc").limit(10)
  }


  def get_domain
    AppConfig[:remote_image_domain]
  end


  def wide_avatar_url
    if self.brand
      self.brand.wide_avatar_url.to_s
    else
      "/assets/img.jpg"
    end
  end

  def white_avatar_url
    if self.brand
      self.brand.white_avatar_url.to_s
    else
      "/assets/img.jpg"
    end
  end

  def black_avatar_url
    if self.brand
      self.brand.black_avatar_url.to_s
    else
      "/assets/img.jpg"
    end
  end

  def brand
  end


  def get_user
    if self.user_id
      u = User.find_by_id(self.user_id)
      if u
        return u
      end
    end
    User.find_by_id(1)
  end


  def get_img_width
    "300"
  end

  def get_img_height
    "400"
  end

  def get_scaled_img_width
    "350"
  end

  def get_scaled_img_height
    if self.get_first_photo and self.get_first_photo.height
      scaled_height = 350*self.get_first_photo.height/self.get_first_photo.width
      scaled_height.to_s
    else
      "350"
    end
  end

  def share_url
    if self.sku_id
      "http://m.shangjieba.com/weixin/sku?id=" + self.sku_id.to_s
      #"http://www.shangjieba.com/weixin/item?from=app&id=" + self.url
    elsif self.category_id == 1000 or self.category_id == 1001
      self.share_dp_url
    else
      #"http://www.shangjieba.com/weixin/items"
      return "http://shangjieba.com" + "/dapeis/#{self.url}/share_selfie"
    end
  end


  def share_title
    self.show_title[0, 200]
  end

  def share_desc
    self.get_desc[0, 200]
  end


  def share_dp_url
    if self.category_id == 1001
      return "http://m.shangjieba.com/weixin/dapei?from=app&id=" + self.url
    end
    if self.category_id == 1000
      return "http://m.shangjieba.com" + "/dapeis/#{self.url}/collection_show"
    end
    return ""
  end

  #need to be added to the column directly later to decreas the query times for the db.
  def shop_url
    if shop
      self.shop.url
    else
      ""
    end
  end

  def name
    self.get_title
  end

  def phone_number
    if self.shop
      self.shop.phone_number
    else
      ""
    end
  end

  def get_display_price
    self.price.sub("￥", "")
  end

  def has_liked?
    if User.current_user and Like.has_liked?(User.current_user.id, self.id, "Item")
      return true
    else
      return false
    end
  end

  def like_id
    return 0 if not User.current_user
    like=Like.find_by_user_id_and_target_id_and_target_type(User.current_user.id, self.id, "Item")
    if like
      like.id
    else
      0
    end
  end

  def like_id_s
    like_id.to_s
  end

  def img_url(size)
    img_url=get_pod_url+"/assets/img.jpg"
    #if self.display_photos and self.display_photos.length>0
    #  self.display_photos.sort_by{|photo| photo.created_at}
    #  photo=self.display_photos.first
    #  img_url=photo.url(size)
    #end
    photo = self.get_first_photo
    if photo
      img_url=photo.url(size)
    end
    img_url
  end

  def img_url_with_width(size)
    re={}
    img_url=get_pod_url+"/assets/img.jpg"
    re[:img_url]=img_url
    re[:width]=300
    re[:height]=300
    #if self.display_photos and self.display_photos.length>0
    if true
      #self.display_photos.sort_by{|photo| photo.created_at}
      photo=self.get_first_photo
      if not photo
        return re
      end
      img_url=photo.url(size)
      re[:img_url]=img_url
      if size != :normal_medium
        re[:width] = photo.width
        re[:height] = photo.height
      else
        re[:width] = 300
        re[:height] = 400
      end
    end
    re
  end

  def img_urls(size)
    img_urls=Array.new
    default_url=get_pod_url+"/assets/img.jpg"
    temp={:img_url => default_url, :width => "300", :height => "300"}
    if self.display_photos and self.display_photos.length>0
      self.display_photos.each do |photo|
        temp = {}
        if size == :api_big
          temp[:img_url]=photo.url(:scaled_full)
          temp[:img_url] = temp[:img_url].gsub("img.shangjieba", "www.shangjieba")
        else
          temp[:img_url]=photo.url(size)
        end
        if not photo.width and not photo.height
          photo.get_dimensions
        end
        temp[:width]=photo.width
        temp[:height]=photo.height
        temp[:height] = photo.width unless photo.height
        img_urls<<temp
      end
    else
      img_urls<<temp
    end
    img_urls
  end

  def thumb
    img_url(:thumb_small)
  end

  def to_param
    url
  end

  def get_display_title
    self.get_title.slice(0, 20).gsub(/\s\w+\s*$/, '...')
  end

  def get_display_photo
    photo=nil
    if self.photos and self.photos.length>0
      self.photos.sort_by { |photo| photo.created_at }
      photo=self.photos.last
    end
    photo
  end

  def incr_and_get_dispose_count
    self.incr_dispose
    self.get_dispose_count
  end

  def get_dispose_count
    if true
      if $redis.get("item_#{self.url}")
        $redis.get("item_#{self.url}").to_i * 10 + rand(10)
      else
        self.dispose_count.to_i * 10 + rand(10)
      end
    end
  end

  def show_title
    if self.title =="hello title"
      return "我的搭配秘书"
    else
      return self.title.to_s
    end
    
  end

  def recommend_title
    title = ""
    if self.price and self.price != ""
      title += self.get_show_price
    end
    if self.shop
      title += " "+self.shop.display_name
    end
    title += self.get_title
    if self.shop_street != ""
      title += "-#{self.shop_street}"
    end
    title
  end

  def get_user_name
    @user=User.find(self.user_id)
    @user.name
  end

  def get_brand_intro
    intro=""
    @shop=self.shop
    if @shop.brand_intro and @shop.brand_intro!=""
      intro=@shop.brand_intro
    elsif @shop.brand and @shop.brand.brand_intro and @shop.brand.brand_intro!=""
      intro=@shop.brand.brand_intro
    end
  end

  def self.newer(shop, item, count=1)
    if count == 1
      where("items.shop_id = ? and items.created_at > ?", shop.id, item.created_at).reorder('items.created_at ASC').first
    else
      where("items.shop_id = ? and items.created_at > ?", shop.id, item.created_at).reorder('items.created_at ASC').first(count)
    end
  end

  def self.older(shop, item, count=1)
    if count ==1
      where("items.shop_id = ? and items.created_at < ?", shop.id, item.created_at).reorder('items.created_at DESC').first
    else
      where("items.shop_id = ? and items.created_at < ?", shop.id, item.created_at).reorder('items.created_at DESC').first(count)
    end
  end


  def display_title
    "#{self.get_show_price}  #{self.shop_name}"
  end

  def show_name
    if self.shop
      "#{self.shop.display_name}#{self.name}"
    else
      self.name
    end
  end

  def upload_date
    "上传于 #{self.created_at.strftime('%Y-%m-%d')}"
  end


  def upload_date1
    self.created_at.strftime('%Y-%m-%d')
  end

  def display_photos
    if self.sku
      self.sku.display_photos
    else
      self.photos
    end
  end

  def get_first_photo
    if self.sku
      self.sku.get_first_photo
    else
      self.photos.first
    end
  end

  def first_photo
    self.display_photos.first
  end

  def get_currency
    if self.sku
      currency = self.sku.get_currency
      if currency == "" or currency != nil
        return currency
      end
      bcurrency = self.sku.brand.currency
      if bcurrency and bcurrency != ""
        return bcurrency
      end
    end
    return "¥"
  end

  def get_price
    if self.sku
      self.sku.get_price
    else
      self.price
    end
  end

  def get_currency_rate(currency_name)
    currency_rate = CurrencyRate.find_by_name(currency_name)
    currency_rate.rate
  end

  def translate_currency_rate(item_currency, link_buy_url="")

    currency_rate = 0
    if item_currency != "¥"
      case item_currency
        when /\$/
          currency_name = "USD"
        when /€/
          currency_name = "EUR"
        when /£/
          currency_name = "GBP"
        else
          currency_name = "CNY"
      end

      case link_buy_url
        when /madewell.com/
          currency_name = "USD"
        when /abercrombie.com/
          currency_name = "HKD"
      end

      currency_rate = get_currency_rate(currency_name)
    end
    currency_rate
  end

  def get_show_price
    item_currency = self.get_currency
    item_get_price = self.get_price
    link_buy_url = self.sku.buy_url
    currency_rate = translate_currency_rate(item_currency, link_buy_url)
    item_currency = "¥"

    if  item_get_price && !item_get_price.strip.empty?
      price = item_get_price.gsub(/\.0+$/, "")
      if price.include?(item_currency)
        price = price.gsub(item_currency, "")
      end
      calc_price = (currency_rate > 0) ? calc_cny(currency_rate, price) : price
      item_currency + calc_price
    else
      ""
    end
  end

  def calc_cny(currency_rate, price)
    price = (price.to_f * currency_rate).round
    price.to_s
  end

  def get_origin_price
    item_currency = self.get_currency
    link_buy_url = self.sku.buy_url
    currency_rate = translate_currency_rate(item_currency, link_buy_url)
    new_item_currency = "¥"
    if self.sku
      item_get_origin_price = self.sku.get_origin_price
    else
      item_get_origin_price = self.origin_price.to_s
    end
    if  item_get_origin_price && !item_get_origin_price.strip.empty?
      price = item_get_origin_price.gsub(/\.0+$/, "").match(/[\d\.,]+/).to_s
      if price.include?(item_currency)
        price = price.gsub(item_currency, "")
      end
      calc_price = (currency_rate > 0) ? calc_cny(currency_rate, price) : price
      calc_price.to_s
    else
      ""
    end
  end

  def format_price(price)
    if price
      price = price.downcase
      price = price.gsub(/￥|cny|usd|hsd|¥|rmb|\$|£|gbp/, "")
      price = price.gsub("''", "")
      price = price.gsub(/\.\d+$/, '')
    end
  end


  def get_num_price
    price=self.get_price
    format_price(price)
  end


  def get_num_origin_price
    price=self.origin_price
    if price.blank?
      price=self.get_origin_price
    end
    format_price(price)
  end


  def get_desc
    ""
  end

  def get_buy_url
    if self.sku and self.sku.buy_url and not self.sku.deleted
      if self.sku.from == "homepage" or self.sku.from == "homepage/mywish"
        #return self.sku.buy_url

        return "http://www.shangjieba.com:8080/skus/#{self.sku.id}/redirect"
      end
    end
    ""
  end

  def get_buy_domain
    if self.sku and self.sku.buy_url
      if self.sku.from == "homepage"
        return self.sku.buy_domain
      end
    end
    ""
  end

  def brand_name
    if self.sku
      self.sku.brand_name
    elsif self.shop
      self.shop.name
    else
      ""
    end
  end

  def brand_id
    if self.sku
      self.sku.brand.id.to_s
    else
      "-1"
    end
  end

  def category_name
    if self.sku
      self.sku.category_name
    else
      ""
    end
  end

  def incr_dispose
    key = "item_#{self.url}"
    $redis.incr(key)
  end

  def brand_avatar_url
    self.shop.brand_avatar_url.to_s
  end

  def get_recommend
    Recommend.find_by_recommended_type_and_recommended_id("Item", self.id)
  end


  def get_title
    if self.sku
      self.sku.title
    else
      self.title
    end
  end


  def get_url
    if self.url
      self.url
    else
      self.sku_id
    end
  end

  def transform
    if self.category_id == 1001
      return Dapei.find_by_id(self.id)
    elsif self.category_id ==1002
      return Selfie.find_by_id(self.id)
    elsif self.category_id == 1000
      return Collection.find_by_id(self.id)
    else
      return self
    end
  end

  # def get_dpimg_urls
  #   imgs = []
  #   if self.category_id == 1000 or self.category_id == 1001
  #     return self.transform.get_dpimg_urls
  #   else
  #     imgs
  #   end
  # end

  def share_img
    img = ''
    if self.category_id == 1001
      #img = self.transform.img_url('y_s')
      if self.transform
        img = self.transform.img_url
      end
    end
    if self.category_id == 1000
      if self.transform
        img = self.transform.img_url
      end
    end
    if self.category_id == 1002
      if self.transform
        img = self.transform.img_url
      end
    end
    img
  end

  def get_items_count
    if self.category_id == 1000 or self.category_id == 1001
      if self.transform
        return self.transform.get_items_count
      else
        0
      end 
    else
      0
    end
  end

  def user_img_small
    if self.get_user
      self.get_user.display_img_small
    else
      ""
    end
  end

  def get_template
    if self.category_id == 1001
      self.dapei_info.get_template if self.dapei_info
    end
  end

  def get_editor_desc
    desc=""
    desc=self.desc unless self.desc.blank?
    if self.category_id == 1001
      if self.dapei_info
        desc=self.dapei_info.comment unless self.dapei_info.comment.blank?
      end
    end
    if desc == "hello description"
      return ""
    else
      return desc
    end
  end

  def dapei2collection
    if self.category_id == 1000
      self.type = 'Collection'
      self.save
    end
    if self.dapei_info
      self.dapei_info.dapei_item_infos.each do |i|
        self.relations.create(:target_id => i.sku.id, :target_type => "Sku") if i.sku
      end
    end
  end

  def get_buy_status
    return self.sku.get_buy_status if self.sku
    "0"
  end

  def self.get_star
    Dapei.where("level >= 5").last
  end

  def self.cache_recommended_all_by_category_id(category_id)
    Rails.cache.fetch "recommend/all_items/category_id/#{category_id}", :expires_in => 3.minutes do
      Dapei.recommended_all(category_id).limit(5).entries
    end
  end

  def get_matter_img
    return self.sku.get_matter_img if self.sku
  end

  def rand_like(xz = false)
    if xz or self.likes_count < 10+rand(20)
      to_like_num = rand(20) + 5
      for n in (1..to_like_num)
        uid = rand(29500)
        user = User.find_by_id(uid)
        if user
          p user.name, 'like item:', self.url
          user.like!('Item', self.url)
        end
      end
    end
  end

  def rand_liked
    to_like_num = rand(2) + 1
    for n in (1..to_like_num)
      uid = rand(29500)
      user = User.find_by_id(uid)
      if user
        user.like!('Item', self.url)
        if self.get_user.followers_count < 500
          user.follow(self.get_user)
        end
      end
    end
  end


  def rand_follow
    to_like_num = 1000 + rand(100)
    for n in (1..to_like_num)
      uid = rand(29500)
      user = User.find_by_id(uid)
      if user
        p user.name, 'follow author=', self.url
        user.follow(self.get_user)
      end
    end
  end


  def self.by_url(url)
    dp = Item.find_by_url(url)
    return dp if dp
    cells = url.split('@')
    if cells.length == 2
      dp = Item.find_by_url(cells[0])
      u = User.find_by_url(cells[1])
      dp.user_id = u.id if dp and u
      return dp if dp
    end
  end

  def self.v4_api_deleted(id)
    Item.find_by_url(id).update_attributes(:deleted =>1)
  end

  # api 精选
  def self.v4_api_choiceness
    Item.where('items.level >= 2').includes(:user,:likes => :user,:dapei_info => :dapei_item_infos).order("items.show_date desc")
  end

  # api 最新
  def self.v4_api_new
    @items = Item.where("(items.level >= 0 or items.level is null) and deleted is null and dapei_info_flag is null").includes(:user,:likes => :user,:dapei_info => :dapei_item_infos).order("items.created_at desc")
  end

  # api follow
  def self.v4_api_follow(cuid)
    cu = User.find cuid
    following_users = cu.following_by_type('User')
    user_ids = following_users.map { |u| u.id }
    user_ids << cu.id
    cond = {:user_id => user_ids}
    Item.where("items.level >= 0 or items.level is null").where(cond).includes(:user,:likes => :user,:dapei_info => :dapei_item_infos).order("items.created_at desc") 
  end

  # api tagged
  def self.v4_api_tagged(tag)
    @item = Item.tagged_with(tag).where('items.deleted is null').uniq.order("created_at desc")
  end
     

  def self.v4_api_liked_by(uid)
    Item.joins(:likes).where(:likes => {:user_id => uid}).order("likes.created_at desc")
  end
 

  def self.v4_api_created_by(uid)
    Item.where(:user_id => uid).includes(:user,:likes => :user,:dapei_info => :dapei_item_infos).order("items.created_at desc") 
  end

  #
  def get_api_tags
    #self.ctags.pluck(:name)
    ctag = []
    if self.ctag_list
      ctag = self.ctag_list.remove("0")
      ctag = ctag.join(",").split(",")
    end
    ctag
  end


  private

  def get_pod_url
    pod_url = AppConfig[:pod_url].dup
    pod_url.chop! if AppConfig[:pod_url][-1, 1] == '/'
    pod_url
  end

  def send_notifications
    #author = self.user
    if self.category_id == 1000 or self.category_id == 1001
      begin
        DapeiNotifyJob.perform_async(self.url)
      rescue => e
        p e.to_s
      end
      self.rand_liked
    end

    if self.get_user
      self.get_user.update_dapei_counter
    end
  end
end
