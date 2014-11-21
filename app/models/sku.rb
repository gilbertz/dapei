# -*- encoding : utf-8 -*-

class Sku < ActiveRecord::Base
  include Sjb::Likeable
  include Sjb::Commentable
  acts_as_taggable

  validates :title, :presence => true
  validates :category_id, :presence => true
  attr_accessible :title, :price, :shop_id, :category_id, :photos, :brand_id, :docid, \
    :desc, :from, :buy_url, :deleted, :publish, :origin_price, :tags, :pno, :color, :color_url, \
    :sizes, :imgs, :tags, :labels, :head, :off_percent, :raw_imgs, :level, :s_price, :priority, :spider_id, :has_discount, \
    :sold_count, :store_count, :comments_count, :tag_list, :sub_category_id, :rate_score, :origin_platform, :is_agent, :is_guide, :freight
  belongs_to :brand, :inverse_of => :skus, :counter_cache => true
  belongs_to :category
  belongs_to :sub_category, :class_name => "Category", :foreign_key => "sub_category_id"
  has_many :items, :inverse_of => :sku, :dependent => :destroy #, :o
  has_many :photos, :as => :target #, :dependent=>:destroy
  has_many :sku_promotions

  acts_as_commentable
  #acts_as_url :title
  acts_as_taggable_on :tags

  attr_accessor :collection_id

  has_many :sku_properties

  # 单品搭配对象,指向同类SKU 集合
  has_one :relation, :as => :target
  has_one :collection,:through => :relation ,:source => :item


  acts_as_api
  api_accessible :public, :cache => 180.minutes do |t|
    t.add :id
    t.add :url, :as => :sku_id
    t.add :title
    t.add :get_show_price, :as => :price
    t.add :currency
    t.add :category
    t.add :brand_name
    t.add :brand_id.to_s, :as => :brand_id
    t.add :desc
    t.add lambda { |sku| sku.img_url(:thumb_small) }, :as => :img_sqr_small
    t.add lambda { |sku| sku.img_url(:thumb_large) }, :as => :img_sqr_medium
    t.add lambda { |sku| sku.img_url(:normal_small) }, :as => :img_normal_small
    t.add lambda { |sku| sku.img_url(:normal_medium) }, :as => :img_normal_medium
    t.add lambda { |sku| sku.img_url(:normal_medium) }, :as => :img_scaled_large
    t.add lambda { |sku| sku.img_urls(:scaled_large) }, :as => :img_urls_medium
    t.add lambda { |sku| sku.img_urls(nil) }, :as => :img_urls_large
    t.add :created_at
    t.add :updated_at
    t.add :buy_domain
    t.add :redirect_buy_url, :as => :buy_url
    t.add :wide_avatar_url
    t.add :white_avatar_url
    t.add :black_avatar_url
  end

  acts_as_api
  api_accessible :priv, :cache => 180.minutes do |t|
    t.add :url, :as => :sku_id
    t.add :title
    t.add :brand_name
    t.add :brand_id.to_s, :as => :brand_id
    t.add lambda { |sku| sku.img_url(:wide_small) }, :as => :img_wide_small
    t.add lambda { |sku| sku.img_url(:wide_half) }, :as => :img_wide_half
    t.add lambda { |sku| sku.img_url(:normal_medium) }, :as => :img_normal_medium
    t.add :created_at
    t.add :updated_at
    t.add :buy_domain
    t.add :buy_url
    t.add :wide_avatar_url
    t.add :white_avatar_url
    t.add :black_avatar_url
  end


  scope :recommended, lambda { |cat_id|
    joins("INNER JOIN recommends ON recommends.recommended_id = skus.id").where("skus.category_id=#{cat_id} and skus.deleted is null").where('recommends.recommended_type' => "Sku").order("recommends.updated_at desc").limit(10)
  }

  scope :recommended_sku, lambda {
    joins("INNER JOIN recommends ON recommends.recommended_id = skus.id").where("skus.category_id < 100 and skus.deleted is null").where('recommends.recommended_type' => "Sku").order("recommends.updated_at desc").limit(10)
  }

  scope :showing, lambda { |count|
    joins("INNER JOIN recommends ON recommends.recommended_id = skus.id").where("skus.category_id < 100").where("skus.deleted=false or skus.deleted is null").where('recommends.recommended_type' => "Sku").order("recommends.updated_at desc").limit(count)
  }

  scope :recomm, lambda { |page, limit|
    joins("INNER JOIN recommends ON recommends.recommended_id = skus.id").where("skus.category_id < 100").where("skus.deleted=false or skus.deleted is null").where('recommends.recommended_type' => "Sku").order("recommends.updated_at desc").paginate(:page => page, :per_page => limit)
  }


  scope :liked_by, lambda { |user|
    joins(:likes).where("skus.category_id<100").where("skus.level>=4").where(:likes => {:user_id => user.id}).order("likes.created_at desc")
  }


  def redirect_buy_url
    "http://www.shangjieba.com:8080/skus/#{self.id}/redirect"
  end


  #这个sku的汇率
  def currency_rate
    self.get_sku_currency_rate
  end

  #实际价格
  def real_price
    # (self.price.to_f * self.currency_rate).round(2)
    self.get_get_show_price_number
  end

  #运费
  def ship_fee
    self.get_freight
  end


  def wide_avatar_url
    if self.brand
      self.brand.wide_avatar_url
    end
  end

  def white_avatar_url
    if self.brand
      self.brand.white_avatar_url
    end
  end

  def black_avatar_url
    if self.brand
      self.brand.black_avatar_url
    end
  end

  def imgs
  end

  def imgs=(tub)
  end

  def get_title
    self.title
  end

  def name
    self.title
  end

  def img_url(size)
    img_url=get_pod_url+"/assets/img.jpg"
    if self.photos and self.photos.length>0
      photo=self.get_first_photo
      img_url=photo.url(size) if photo
    end
    img_url
  end

  def matter_img_url(size)
    img_url=get_pod_url+"/assets/img.jpg"
    if self.photos.where(:is_send => 1).present?
      photo=self.photos.where(:is_send => 1).first
      img_url=photo.url(size)
    end
    img_url
  end

  def display_photos
    #self.photos.order('is_send desc')
    self.photos.where('remote_photo_name is not null').order('is_send desc')
  end

  def get_first_photo
    self.display_photos.first
  end

  def img_urls(size)
    img_urls=Array.new
    default_url=get_pod_url+"/assets/img.jpg"
    temp={:img_url => default_url, :width => "300", :height => "300"}
    if self.photos and self.photos.length>0
      self.display_photos.each do |photo|
        temp = {}
        if size == :api_big
          temp[:img_url]=photo.url(:scaled_full)
          if temp[:img_url]
            temp[:img_url] = temp[:img_url].gsub("img.shangjieba", "www.shangjieba")
          end
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

  def get_typed_img_sets
    #define four types: wide, half, normal, square
    img_sets={}
    wide_set=[]
    half_set=[]
    normal_set=[]
    squre_set=[]
    if self.photos and self.photos.length>0
      self.photos.each do |photo|
        width=photo.width
        height=photo.height
        ratio=(width+1.0)/(height+1.0)
        if ratio>2
          wide_set<<photo
        elsif ratio>1.3
          half_set<<photo
        elsif raio>0.9
          squre_set<<photo
        else
          normal_set<<photo
        end
      end
    end
    img_sets[:wide]=wide_set
    img_sets[:half]=half_set
    img_sets[:normal]=normal_set
    img_sets[:squre]=square_set
  end

  def brand_name
    if self.brand
      if self.brand.display_name
        self.brand.display_name
      else
        self.brand.name
      end
    end
  end

  def upload_date
    "上传于 #{self.created_at.strftime('%Y-%m-%d')}"
  end

  def self.get_currency_rate_val(currency_sign, link_buy_url="")
    currency_name = Sku.get_currency_name(currency_sign, link_buy_url)
    currency_rate = self.get_currency_rate(currency_name)
    return currency_rate.round(2)
  end

  def self.get_currency_name(currency_sign, link_buy_url="")
    case currency_sign
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
    return currency_name
  end

  def get_sku_currency_rate
    sku_currency = self.get_currency
    sku_buy_url = self.buy_url
    sku_currency_rate_val = Sku.get_currency_rate_val(sku_currency, sku_buy_url)
    return sku_currency_rate_val
  end

  def sync
    self.items.each do |item|
      item.title = self.title
      item.category_id = self.category_id
      item.price = self.price
      item.origin_price = self.origin_price
      item.off_percent = self.off_percent
      item.tags = self.tags
      item.save
    end
  end

  def buy_domain
    if self.buy_url
      self.buy_url.gsub(/https?:\/\//, "").split("/")[0]
    else
      ""
    end
  end

  def categorize
    if self.brand
      $cat_dict.each do |k, v|
        title = self.title.gsub("T 恤", "T恤")
        title = title.downcase.gsub("包邮", "")
        if title.index(k.downcase)
          cat = Category.find_by_name(v)
          if category and cat
            self.category_id = cat.id
            #self.tags = cat.name
            p self.title, v, k
            self.save
            break
          end
        end
      end
    end
  end

  def get_currency
    if self.buy_url and (self.buy_url.index("tmall.com") or self.buy_url.index("yintai.com"))
      return "￥"
    end
    if not self.currency or self.currency == ""
      "￥"
    else
      self.currency
    end
  end

  def get_price
    #self.format_price if /^[\d\.]+$/ !~ self.price
    self.price.to_s
  end

  def self.get_currency_rate(currency_name)
    currency_rate = CurrencyRate.find_by_name(currency_name)
    currency_rate.rate
  end

  def get_show_price
    item_currency = self.get_currency
    item_price = self.price
    link_buy_url = self.buy_url
    currency_rate = 0

    if item_currency != "¥"
      currency_name = Sku.get_currency_name(item_currency, link_buy_url)
      currency_rate =Sku.get_currency_rate(currency_name)
      item_currency = "¥"
    end

    if  item_price && !item_price.strip.empty?
      price = item_price.gsub(/\.0+$/, "")
      if price.include?(item_currency)
        price = price.gsub(item_currency, "")
      end
      calc_price = (currency_rate > 0) ? calc_cny(currency_rate, price) : price
      item_currency + calc_price
    end
  end

  def get_get_show_price_number
    item_currency = self.get_currency
    item_price = self.price
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

      currency_rate = Sku.get_currency_rate(currency_name)
      item_currency = "¥"
    end

    if  item_price && !item_price.strip.empty?
      price = item_price.gsub(/\.0+$/, "")
      if price.include?(item_currency)
        price = price.gsub(item_currency, "")
      end
      calc_price = (currency_rate > 0) ? calc_cny(currency_rate, price) : price
      calc_price.to_f
    else
      ""
    end
  end

  def get_show_price_currency
    item_currency = self.get_currency
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

      currency_rate = Sku.get_currency_rate(currency_name)
      item_currency = "¥"
    else
      item_currency = "¥"
    end
    item_currency
  end

  def calc_cny(currency_rate, price)
    price = (price.to_f * currency_rate).round
    price.to_s
  end

  def get_origin_price
    if self.origin_price != self.price
      self.origin_price.to_s
    else
      ""
    end
  end

  def trans_comma
    price = self.price.downcase
    origin_price = self.origin_price.downcase

    case self.buy_url
      when /zalando.de/
        price = price.gsub(/(.*)([,，])(.*)/, '\1.\3')
        origin_price = origin_price.gsub(/(.*)([,，])(.*)/, '\1.\3')
      else
    end
    price = price.gsub(",", "")
    origin_price = origin_price.gsub(",", "")

    [price, origin_price]
  end

  def self.parse_currency_sign(doc_price)
    case doc_price
      when /hkd|hk\$/
        currency = "HK $"
      when /\$|usd|美元/
        currency = "$"
      when /€|eur/
        currency = "€"
      when /£|gbp/
        currency = "£"
      else
        currency = "¥"
    end
    currency
  end

  def parse_price(price, origin_price, currency)

    if not /^[\d\.,]+$/.match(price)
      m = /([¥￥\$€\$£€]|rmb|usd|eur|gbp|cny)(.*?)([\d\.,]+)/.match(price)
      if m
        price = m[3]
      end
    end

    pat1 = /[¥£￥€\$\s+,，]|cny|rmb|usd|eur|hkd|gbp/
    pat2 = /售价：|市场价：|店庆价:/

    price = price.gsub(pat1, "").gsub(pat2, "").gsub("''", "").gsub("€\nor add to my wishlist", "").gsub(/\.0+$/, "")
    origin_price = origin_price.gsub(pat1, "").gsub(pat2, "").gsub(/\.0+$/, "")
    price, origin_price = parse_dot(price, origin_price, currency)

    [price, origin_price]
  end

  def parse_dot(price, origin_price, currency)
    case currency
      when /€|£|\$/
        parsed_price = price
        parsed_origin_price = origin_price
      when /¥|￥/
        parsed_price = price.gsub(/\.\d+$/, "")
        parsed_origin_price = origin_price.gsub(/\.\d+$/, "")
      else
        parsed_price = price
        parsed_origin_price = origin_price
    end
    [parsed_price, parsed_origin_price]
  end

  def format_price

    price, origin_price = trans_comma

    pat = /[¥￥\$ $£]([\d\.,]+)(.*?)[¥￥\$ $£]([\d\.,]+)/

    if pat != ""
      m = /#{pat}/.match(price)
      if m
        if m[1].to_i > m[3].to_i
          price = m[3]
          origin_price = m[1]
        else
          price = m[1]
          origin_price = m[3]
        end
      end
    end

    currency = Sku.parse_currency_sign(self.price)
    parsed_price, parsed_origin_price = parse_price(price, origin_price, currency)

    self.price = parsed_price.strip
    self.origin_price = parsed_origin_price.strip
    if self.currency.nil? || self.currency.empty?
      self.currency = currency.strip
    end

    self.save

  end

  scope :recommended_lookbooks, lambda {
    joins("INNER JOIN recommends ON recommends.recommended_id = skus.id").where("skus.category_id = 103").where("recommends.recommended_type = 'Sku' ").order("recommends.updated_at desc").limit(20)
  }

  def matter_photos
    self.photos.where(:is_send => 1)
  end

  def level_shop
    self.brand.shops.each do |s|
      p s.name
      if s.level != nil and s.level.to_i >= 2 and s.level.to_i < self.level.to_i
        s.level = self.level
        s.save
      end
    end
  end

  def level_sku
    sku = self
    b = self.brand

    #if b and b.level < 3
    #  b.shops.each do |s|
    #    if s and s.level and s.level >= 3
    #       s.level = b.level
    #       s.save
    #    end
    #  end
    #b.skus.each do |sku|
    #  sku.items.each do |item|
    #    if item.level and item.level >= 3
    #      item.level = b.level
    #      item.save
    #    end
    #  end
    #end
    #end

    p b.level
    if b and b.level.to_i >=3 and not sku.deleted and sku.category_id < 100 and 90.days.since(sku.created_at) > Time.now
      if sku.from =~ /homepage/
        print "5:", sku.title, b.name, "homepage", "\n"
        sku.level = 5
        sku.priority = b.priority
        sku.save
        #sku.items.each do |item|
        #  item.level = 5
        #  item.save
        #end
      elsif sku.from == "weibo"
        if b.level < 5
          print b.level, sku.title, b.name, "weibo\n"
          sku.level = b.level
          sku.priority = b.priority
          sku.save
        else
          print 2, sku.title, b.name, "weibo!!!\n"
          sku.level = 2
          sku.save
        end
      elsif (not sku.from or sku.from == "") and b.level >= 5
        print b.level, sku.title, b.name, "upload", "\n"
        sku.level = b.level
        sku.priority = b.priority
        sku.save
        #sku.items.each do |item|
        #  item.level = b.level + 1
        #  item.save
        #end
      end
      #self.level_shop
    end
  end

  def sync_to_shop
    self.brand.shops.where("level > 2").each do |s|
      sku = self
      if not sku.deleted and sku.category_id < 100 and 60.days.since(sku.created_at) > Time.now and sku.level.to_i >= 3
        next if sku.photos.length <= 0
        item = Item.find_by_shop_id_and_sku_id(s.id, sku.id)
        unless item
          print sku.title, sku.id, " for ", self.url, "\n"
          Item.create(:shop_id => s.id, :sku_id => sku.id, :from => sku.from, :title => sku.title+"  "+sku.id.to_s, :category_id => sku.category_id, :price => sku.price, :origin_price => sku.origin_price, :off_percent => sku.off_percent, :tags => sku.tags, :level => sku.level)
        end
      end
    end
  end

  def wrap_item(shop_id=nil)
    item = Item.new(:shop_id => shop_id, :title => self.brand.name + " " + self.title, :sku_id => self.id, :level => self.level)
    item.likes_count = self.likes_count
    item.comments_count = self.comments_count
    item.dispose_count = self.dispose_count
    item.get_dispose_count = self.get_dispose_count
    item
  end

  def remove
    self.items.each do |item|
      #item.destroy
      item.deleted = true
      item.save
    end
    self.deleted = true
    self.save!
  end

  def get_dispose_count
    if $redis.get("sku_#{self.id}")
      $redis.get("sku_#{self.id}")
    else
      self.dispose_count
    end
  end


  def incr_dispose
    key = "sku_#{self.id}"
    $redis.incr(key)
  end


  def like_id
    return 0 if not User.current_user
    like=Like.find_by_user_id_and_target_id_and_target_type(User.current_user.id, self.id, "Sku")
    if like
      like.id
    else
      0
    end
  end


  def img_url_with_width(size)
    re={}
    img_url=get_pod_url+"/assets/img.jpg"
    re[:img_url]=img_url
    re[:width]=300
    re[:height]=300
    if true
      photo=self.display_photos.first
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


  def category_name
    if self.category.id > 10 and self.category.id < 15
      self.category.name + " 女装"
    else
      self.category.name
    end
  end

  def sub_category_name
    sub_category = Category.find_by_id(sub_category_id)
    if sub_category
      sub_category.name
    end
  end


  def get_num_price
    self.get_price
  end

  def get_num_origin_price
    self.get_origin_price
  end
 #
 #
 # def get_buy_url
 #   #if self.buy_url && self.buy_url.index('tmall.com')
 #   #  tmall_id = self.buy_url.gsub(/(.*)id=(\d+)/,  '\2')
 #   #  return 'http://makefashion.ai.m.jaeapp.com/web/add.php?id=' + tmall_id
 #   #end
 #   return self.buy_url
 # end

  def get_buy_url
    #if self.buy_url && self.buy_url.index('tmall.com')
      #tmall_id = self.buy_url.gsub(/(.*)id=(\d+)/, '\2')
      #return 'http://makefashion.ai.m.jaeapp.com/web/add.php?id=' + tmall_id
    #end
    return self.buy_url
  end



  def get_buy_url_old
    if self.buy_url
      if self.from == "homepage" or self.from == "homepage/mywish"
        return self.buy_url
      end
    end
    "#"
  end

  def get_desc
    self.desc
  end

  def get_brand_intro
    self.brand.brand_intro
  end


  def self.newer(brand, sku, count=1)
    if count == 1
      where("skus.brand_id = ? and skus.created_at > ?", brand.id, sku.created_at).reorder('skus.created_at ASC').first
    else
      where("skus.brand_id = ? and skus.created_at > ?", brand.id, sku.created_at).reorder('skus.created_at ASC').first(count)
    end
  end

  def self.older(brand, sku, count=1)
    if count ==1
      where("skus.brand_id = ? and skus.created_at < ?", brand.id, sku.created_at).reorder('skus.created_at DESC').first
    else
      where("skus.brand_id = ? and skus.created_at < ?", brand.id, sku.created_at).reorder('skus.created_at DESC').first(count)
    end
  end

  def first_photo
    self.display_photos.first
  end

  def sync_to_matters
    ms = Matter.find_all_by_sku_id(self.id)
    ms.each do |m|
      m.tags = self.tag_list.join(' ')
      m.save
    end
  end

  def get_matter
    Matter.find_by_sku_id(self.id)
  end


  def get_matter_img
    dii = DapeiItemInfo.where(:sku_id => self.id).first
    dii.img_url if dii
  end


  def search_dapei(limit=5)
    level = 9
    s = Searcher.new("", "matter", nil, nil, limit, 1)
    s.set_color(self.get_color) if self.get_color != '#000000'
    s.set_level(9)
    s.set_sub_category_id(self.sub_category_id) if self.sub_category_id

    matters = s.search()
    dapeis = []
    matters.each do |m|
      dapeis += m.sku.get_sku_dapeis
    end
    dapeis[0, limit]
  end


  def get_dapeis(limit, page)
    dapeis = []
    dapei_item_infos = DapeiItemInfo.where(:sku_id => self.id).page(page).per(limit)
    dapei_item_infos.each do |di|
      dinfo = di.dapei_info
      if dinfo
        dapeis << dinfo.dapei if dinfo.dapei and dinfo.dapei.level.to_i >= 1 and dinfo.dapei.category_id == 1001
      end
    end
    #if dapeis.length < limit and page == 1
    #  dapeis += self.search_dapei(limit)
    #end
    dapeis.uniq
  end

  def get_sku_dapeis(limit=10)
    dps = Dapei.joins("INNER JOIN ( dapei_infos INNER JOIN dapei_item_infos ON dapei_infos.id = dapei_item_infos.dapei_info_id) ON dapei_infos.dapei_id = items.id").where("items.level >= 1").where("items.category_id=1001").where("dapei_item_infos.sku_id = #{self.id}").order("items.created_at desc").limit(limit)
    dps

    #dapei_item_infos = DapeiItemInfo.where(:sku_id => self.id).limit(10)
    #dapei_item_infos.each do |di|
    #  dinfo = di.dapei_info
    #  if dinfo
    #    if dinfo.dapei and dinfo.dapei.level.to_i >= 1
    #      p dinfo.dapei
    #      return dinfo.dapei
    #    end
    #  end
    #end
  end


  def get_buy_status
    return '0' if self.deleted
    if self.spider_id
      spider = Spider.find_by_id(self.spider_id)
      spider = spider.template_spider if spider
      return '1' unless spider

      show_buy = spider.is_agent
      show_origin_link = spider.is_guide
      show_freight = false
      show_freight = true if spider.is_show_freight
      return "2" if show_buy and not show_origin_link and not show_freight
      return "3" if show_buy and not show_origin_link and show_freight
      return "4" if show_buy and show_origin_link and not show_freight
      return "5" if show_buy and show_origin_link and show_freight
    end

    #if self.from == "shangjieba"
    #  return "2"
    #end
    #if self.buy_domain == "www.net-a-porter.com"
    #  return "3"
    #end
    #if self.from == "homepage" and not self.deleted
    #  return "1"
    #end
    return "1"
  end


  def get_freight
    unless self.spider_id.nil?
      spider = Spider.find(self.spider_id)
      spider = spider.template_spider if spider.freight.nil?
      return spider.freight.to_f
    else
      return 0.0
    end
  end

  def self.cache_recommend_sku_by_category_id(category_id)
    Rails.cache.fetch "recommend/skus/#{category_id}", :expires_in => 3.minutes do
      Sku.recommended(category_id).entries
    end
  end

  def self.cache_recommended_lookbooks
    Rails.cache.fetch "recommend/lookbooks", :expires_in => 3.minutes do
      Sku.recommended_lookbooks.entries
    end
  end


  def get_color
    m = Matter.find_by_sku_id(self.id)
    if m
      color = m.get_first_color
      return "#" + color unless color.index('#')
      return color
    else
      return "#000000"
    end
  end


  def get_color_1
    m = Matter.find_by_sku_id(self.id)
    if m
      color = m.get_second_color
      return "#" + color unless color.index('#')
      return color
    else
      return "#000000"
    end
  end


  def trans_likes
    like_users = Like.like_users(self, 1, 1000)
    like_users.each do |u|
      matters = Matter.find_all_by_sku_id(self.id)
      matters.each do |m|
        u.like!('Matter', m.id)
      end
    end
  end

  def make_matter(index=0)
    photo = self.get_first_photo

    unless Matter.find_by_sku_id(self.id)
      matter = Matter.new
      matter.source_type = 1
      matter.sjb_photo_id = photo.id
      matter.sku_id = self.id
      matter.level = 13 if matter.level.to_i == 0
      matter.rule_category_id = self.category_id

      if matter.save
        photo.is_send = 1
        photo.save
        matter.dump
      end
    end
    self.trans_likes
  end

  def sub_category_name
    unless self.sub_category_id.blank?

      if self.sub_category_id == 0
        "无"
      else
        c = Category.find(self.sub_category_id)
        c.try(:name)
      end

    else
      ""
    end
  end

  def check_sub_category
    if self.sub_category_id
      sub_cat = Category.find_by_id(self.sub_category_id)
      if sub_cat and sub_cat.parent_id != self.category_id and self.category.id < 100
        self.sub_category_id = nil
        self.save
      end
    end
  end

  #获取商品的熟悉 尺码颜色
  def get_all_properties
    self.sku_properties
  end

  #获取商品的尺码属性 默认尺码属性的id ＝ 1
  def get_size_properties
    self.sku_properties.where(:property_id => 1)
  end

  #获取商品的颜色属性 默认尺码属性的id ＝ 2
  def get_color_properties
    self.sku_properties.where(:property_id => 2)
  end

  #获取商品状态 是否上线状态
  def online?
    true
  end


  def self.calculate_sub_category(ids)
    require 'rmmseg'
    #RMMSeg::Dictionary.load_dictionaries

    categories = Category.get_all_active_sub_categories

    #add the head dictionary to the dict
    categories.each do |c|

      k = c.name

      if k.length>=2
        RMMSeg::Dictionary.add(k, k.length, 1)
      end

      unless c.synonyms.blank?
        c.synonyms.each do |syn|

          if syn.content.length >= 2

            nk = syn.content.strip
            RMMSeg::Dictionary.add(nk, nk.length, 1)
          end

        end
      end

    end

    puts categories.inspect

    #load the sub cat dictionary.
    sub_cat_dict={}

    cat_list = categories
    cat_list.each do |c|
      sub_cat_dict[c.name]=c.id
      unless c.synonyms.blank?

        c.synonyms.each do |syn|
          w = syn.content.strip
          sub_cat_dict[w] = c.id
          puts "#{c.name} has one synonym #{syn.content}"
        end

      end
    end


    puts "----------all dictionary---------------------"
    puts "#{sub_cat_dict}"
    puts "----------all dictionary---------------------"

    three_month_ago = 3.months.ago.strftime("%Y-%m-%d %H:%M:%S")

    #Sku.where(:id => [173384]).find_each do |sku|
    #Sku.where("sub_category_id is nul").find_each do |sku|


    puts "=======Begin========="
    puts "=======#{ids}======"


    unless ids.blank?
      operate_skus = Sku.where(:id => ids)
    else
      operate_skus = Sku.where("sub_category_id = 0 and created_at > '#{three_month_ago}'")
      puts "-------opeate no sku id-----------"
    end

    operate_skus.find_each do |sku|
      puts sku.inspect

      next if not sku
      next if sku.category_id > 1000
      # next if sku.from !~ /homepage/
      #title = sku.title.gsub(" t 恤", "t桖")
      title = sku.title.gsub("包邮", "").downcase
      title = title.gsub(/指定款(.*)/, '')
      heads=[]
      words = []

      puts "--------------title----------"
      puts title

      algor = RMMSeg::Algorithm.new(title)

      loop do
        tok = algor.next_token
        break if tok.nil?
        #puts tok.text
        words << tok.text.force_encoding("UTF-8")
      end

      puts "---------get 1------------"
      puts "--------#{words.inspect}--------------"
      puts "---------get 1------------"


      unless sku.category_id.blank?

        limit_words = Category.get_all_active_sub_categories(sku.category_id).collect { |c| c.name }

        words.each do |w|
          if limit_words.include?(w)
            heads << w
          end
        end

      end

      if heads.blank?
        words.each do |w|
          if sub_cat_dict.include?(w)
            heads << w
          end
        end
      end

      puts words
      puts "-----------------------words-----------------------"
      puts heads
      puts "-------------------------heads--------------------------"


      # sku_head=select_head(heads, sub_cat_dict)

      unless heads.blank?
        sku_head = heads.last
      end

      puts sku_head
      puts "-------------------------sku_head--------------------------"


      unless sku_head.blank?
        if sub_cat_dict.has_key?(sku_head)
          sku.sub_category_id=sub_cat_dict[sku_head]
        end
      end
      #p "----------------------------------------------"
      #p title
      #p sku.head
      #p sku.tags
      puts "========================"
      puts sku.sub_category_id

      sku.save
    end
  end

  def self.calculate_add_tags(ids)
    require 'rmmseg'

    head_dict = []
    fn = Rails.root + "db/seed/new_tag.txt"
    cat = ""
    File.new(fn).each do |line|
      line = line.strip()
      if line != ""
        word=line.downcase
        next if word.length == 0
        head_dict << word
      end
    end

    head_dict.each do |word|
      if word.length>=2
        RMMSeg::Dictionary.add(word, word.length, 1)
      end
    end

    #TODO
    #skus = Sku.order("id desc").limit(1)

    puts "=======Begin========="

    unless ids.blank?
      operate_skus = Sku.where(:id => ids)
      puts "----------operate #{ids}-----"
    else
      operate_skus = Sku.where(["created_at > ?", 24.hours.ago])
      puts "-------opeate no sku id-----------"
    end

    operate_skus.find_each do |sku|
      title = sku.title
      desc = sku.desc

      context = "#{title} #{desc}"

      algor = RMMSeg::Algorithm.new(context)

      tags = []
      loop do
        tok = algor.next_token
        break if tok.nil?
        word = tok.text.force_encoding("UTF-8")

        if head_dict.member? word
          tags << word
        end
      end

      sku.tag_list = tags.join(",")
      if sku.save
        sku.sync_to_matters
      end
      puts sku.tag_list
      #puts sku.inspect
      puts "=========================="
    end
  end

  #尺码规格转换图
  def size_convert_image
    size_images = {
        "11" => "http://1251008728.cdn.myqcloud.com/1251008728/2014/08/23/top.png",
        "12" => "http://1251008728.cdn.myqcloud.com/1251008728/2014/08/23/bottom.png",
        "4" => "http://1251008728.cdn.myqcloud.com/1251008728/2014/08/23/shoes.png",
        "7" => "http://1251008728.cdn.myqcloud.com/1251008728/2014/08/23/man.png",
        "13" => "http://1251008728.cdn.myqcloud.com/1251008728/2014/08/23/bottom.png"
    }

    size_images[self.category_id.to_s]
  end

  private
  def get_pod_url
    pod_url = AppConfig[:pod_url].dup
    pod_url.chop! if AppConfig[:pod_url][-1, 1] == '/'
    pod_url
  end

end
