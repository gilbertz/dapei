# -*- encoding : utf-8 -*-
class Shop < ActiveRecord::Base
  include Sjb::Likeable
  include Sjb::Commentable 

  validates :name, :presence => true, :length => { :minimum => 1 } 
  #validates :city, :presence => true
  #validates :district, :presence=>true
  #validates :town, :presence=>true #need to consider whether we should add this
  #validates :street, :presence=>true
  #validates :house_number, :presence =>true
  #validates_format_of :house_number, :with => /\A[0-9]+\z/
  validates :url, :uniqueness=>true, :format=>{:with => /^[a-z0-9\-_]+$/}, :allow_blank => true ##, :presence=>true
  #validates :address, :presence=>true
  #validates_format_of :jindu  #need to be specified later
  #validates_format_of :weidu
   
  has_many :items, :inverse_of => :shop, :dependent=>:destroy, :order=>'updated_at DESC'
  has_many :discounts, :as => :discountable, :dependent=>:destroy
  has_many :photos, :as => :target#, :dependent=>:destroy

  belongs_to :mall
  belongs_to :user
  belongs_to :brand, :inverse_of=>:shops, :counter_cache => true
  belongs_to :category
  
  attr_accessible :shop_type, :weibo, :brand_id, :category_id, :mall_id, :price_level, :brand_intro, :name, :url, :city, :city_id, :level, :district, :crawled, :town, :street, :phone_number, :product, :house_number, :address, :area_id, :jindu, :weidu, :level, :user_id, :activated, :item_ids, :open_hours, :avatar_id, :likes_count, :comments_count, :items_count, :dispose_count, :mall, :alias, :dp_id, :tags, :average_price, :bd_uid, :priority
  
  attr_accessor :distance, :cid

  acts_as_commentable
  acts_as_followable

  before_destroy :change_role

  acts_as_api
  api_accessible :public, :cache => 180.minutes do |t|
    t.add :url, :as=>:shop_id
    t.add :get_display_name, :as=>:name
    t.add :get_jindu, :as => :jindu
    t.add :get_weidu, :as => :weidu
    t.add :brand_name
    t.add :brand_id
    t.add :display_name
    t.add :get_street, :as => :street
    t.add :address
    t.add :get_low_price_s, :as=>:low_price
    t.add :get_high_price_s, :as=>:high_price
    t.add :get_brand_intro, :as=>:intro
    t.add lambda{|shop| shop.comments_count.to_s}, :as => :comments_count
    t.add lambda{|shop| shop.get_likes_count.to_s}, :as => :likes_count
    t.add lambda{|shop| shop.items_count.to_s}, :as => :items_count
    t.add lambda{|shop| shop.get_dispose_count.to_s}, :as => :dispose_count
    #t.add :comments_count
    #t.add :likes_count
    #t.add :items_count
    t.add :phone_number
    t.add :product
    t.add :open_hours
    t.add :avatar_url
    t.add :wide_avatar_url
    t.add :white_avatar_url
    t.add :black_avatar_url
    t.add lambda{|shop| shop.showing_img_urls(shop.cid)}, :as => :showing_img_urls
    t.add :get_current_discount, :as=>:discount
    t.add lambda{|shop| shop.img_url(:thumb_medium)}, :as => :img_sqr_medium
    t.add lambda{|shop| shop.img_url(:thumb_small)}, :as => :img_sqr_small
    t.add lambda{|shop| shop.img_url(:wide_medium)}, :as => :img_wide_medium
    t.add lambda{|shop| shop.img_url(:wide_large)}, :as => :img_wide_large
    #t.add :like_id_s , :if=>:has_liked?, :as=>:like_id
    t.add :like_brand_id_s , :as=>:like_id
    t.add lambda{|shop| shop.city_id.to_s},  :as => :city_id
    t.add lambda{|shop| shop.distance.to_s},  :as => :distance
    t.add lambda{|shop| shop.cid.to_s},  :as => :cid
    t.add :share_url
  end

  def get_jindu
    unless self.jindu.blank?
      self.jindu
    else
      "0.0"
    end
  end

  def get_weidu
    unless self.weidu.blank?
      self.weidu
    else
      "0.0"
    end 
  end

  def get_likes_count
    if self.brand
      self.brand.get_likes_count
    else
      self.likes_count
    end
  end

  def wide_avatar_url
    if self.brand
      self.brand.wide_avatar_url
    else
      "/assets/img.jpg"
    end
  end
 
  def white_avatar_url
    if self.brand
      self.brand.white_avatar_url
    else
      "/assets/img.jpg"
    end
  end

  def black_avatar_url
    if self.brand
      self.brand.black_avatar_url
    else
      "/assets/img.jpg"
    end
  end

  def brand_shop_url
    if self.brand
      self.brand.banner_url
    else
      "/assets/img.jpg"
    end
  end

  def shop_shop_url
    if self.brand
      self.brand.shop_img_url(:wide_banner)
    else
      "/assets/img.jpg"
    end
  end

  api_accessible :error do |t|
    t.add :errors
  end

  scope :liked_by, lambda { |user|
    joins(:likes).where(:likes => {:user_id => user.id}).where(:shops=>{:level=> [3,4,5]} ).order("likes.created_at desc")
  }

  scope :commented_by, lambda { |user|
    joins(:comments).where(:comments => {:user_id => user.id})
  }
  
  #scope :recommended,  lambda { |city_id|
  #  where("level=?", 5).where("city_id=?", city_id).order("updated_at desc").limit(10)
  #} 

  scope :recommended,lambda{|city_id|
    joins("INNER JOIN recommends ON recommends.recommended_id = shops.id").where('recommends.recommended_type' => "Shop").where("shops.city_id=#{city_id}").order("recommends.updated_at desc").limit(10)
  }

  before_validation :auto_url
  def auto_url
    if self.url.blank?
      if !self.name.blank?
        self.url=self.name
      end
      if self.url.blank?
        self.url = self.id.to_s
      end
    end
    self.url=self.url.to_url
    old_shop=Shop.find_by_url(self.url)
    if !old_shop.blank? and old_shop.id!=self.id
       self.url=self.url+"_"+Shop.maximum('id').to_s
    end
    self.url = self.url.to_url
  end

  def share_url
    "http://www.shangjieba.com/weixin/shop?from=app&id=" + self.url
  end


  def has_liked?
    if User.current_user and Like.has_liked?(User.current_user.id, self.id, "Shop")
      return true
    else
      return false
    end
  end

  def like_id
    like=Like.find_by_user_id_and_target_id_and_target_type(User.current_user.id, self.id, "Shop")
    like.id
  end

  def like_brand_id
    if self.brand and User.current_user
      like=Like.find_by_user_id_and_target_id_and_target_type(User.current_user.id, self.brand.id, "Brand")
      like.id if like
    end
  end

  def like_brand_id_s
    self.like_brand_id.to_s
  end

  def like_id_s
    like_id="0"
    if has_liked?
      like=Like.find_by_user_id_and_target_id_and_target_type(User.current_user.id, self.id, "Shop")
      like_id=like.id.to_s
    end
    like_id
  end

  def to_param
    url
  end
  
  def thumb
    img_url(:thumb_medium)
  end

  def display_name
    self.name.sub(/\(.*\)/, "")
  end

  def shop_display_name
    self.display_name
  end

  def showing_img_urls(cid=nil)
    img_urls = []
    default_url = get_pod_url+"/assets/img.jpg"
    default = {:img_url=>default_url, :width=>"300", :height=>"300"}

    where = "1=1"
    if cid != nil and cid != ""
      where = "skus.category_id = #{cid}"
    end
    count = 0
    if self.brand
      self.brand.get_rand_skus.each do |sku|
        if not sku.deleted
           img_urls<< sku.img_url_with_width(:normal_medium)
           count += 1
           break if count >= 3
        end
      end
    end

    if count < 3
      for i in 1..3-count do
        img_urls<<default
      end
    end
    img_urls
  end

  def showing_img_urls_web(cid=nil)
    img_urls=Array.new
    default_url=get_pod_url+"/assets/img.jpg"
    count = 0
    if self.brand
      self.brand.get_rand_skus(cid).each do |sku|
        if not sku.deleted
           img_urls<< sku.img_url(:normal_medium)
           count += 1
           break if count >=4
        end
      end
    end
    if count<4
      for i in 1..4-count do
        img_urls<<default_url
      end
    end
    img_urls
  end
  
  def img_url(size)
    img_url=get_pod_url+"/assets/img.jpg"
    if self.photos and self.photos.length>0
      self.photos.sort_by{|photo| photo.created_at}
      photo=self.photos.last
      img_url=photo.url(size)
    elsif self.brand
      img_url=self.brand.shop_photo_url
    end
    img_url
  end

  def avatar_url
    if self.brand
      self.brand.avatar_url
    else
      return avatar.url(:thumb_medium) if avatar
      get_pod_url+"/assets/0.gif"
    end
  end

  def wide_avatar_url
    if self.brand and self.brand.wide_avatar_url
      self.brand.wide_avatar_url
    else
      return avatar.url(:thumb_medium) if avatar
      get_pod_url+"/assets/0.gif"
    end
  end

  def brand_avatar_url
     self.avatar_url
  end

  def avatar
    if self.avatar_id
      Photo.find_by_id(self.avatar_id)
    end
  end

  #the hottest 9 items. Need to be improved later
  def top_hot_items
     self.items.where("level>=3").first(8)
  end

  def get_display_photo
    photo=nil
    if self.photos and self.photos.length>0
      self.photos.sort_by{|photo| photo.created_at}
      photo=self.photos.last
    elsif self.brand
      photo = self.brand.shop_photo
    end
    photo
  end

  def get_display_photo_first
     photo=nil
    if self.photos and self.photos.length>0
      self.photos.sort_by{|photo| photo.created_at}
      photo=self.photos.first
    end
    photo
  end

  def get_last_discount
    unless self.discounts.blank?
      self.discounts.sort_by{|discount| discount.created_at}
      self.discounts.last
    end
  end


  def get_current_discount
    discount = nil
    unless self.discounts.blank?
      self.discounts.sort_by{|discount| discount.updated_at}
      discount=self.discounts.last
    end
    if discount == nil or ( discount.end_date and discount.end_date < Date.today )
      if self.brand
        self.brand.discounts.sort_by{|discount| discount.updated_at}
        discount=self.brand.discounts.last
      end
    end
    if discount and not discount.deleted and discount.end_date and discount.end_date >= Date.today
      return discount
    end
  end

  def get_likers
    @likers=Like.where("target_type='Shop' and target_id=#{self.id}").collect {|l| l.user }
    @likers
  end


  def shop_name
    if self.alias and self.alias != ""
       self.alias
    else
       self.name
    end 
  end

  def recommend_name
    self.display_name + self.shop_street + "店"
  end

  def shop_url
    self.url
  end

  def shop_city
    area = Area.city(self.city_id).first
    if area
       area.city
    else
       ""
    end
  end

  def shop_street
    self.get_street
  end

  def shop_address
    self.address
  end

  def shop_avatar_url
    avatar_url
    #if self.avatar
    #  self.avatar.url(:thumb_medium)
    #else
    #  self.img_url(:thumb_medium)
    #end
  end

 
  def get_dispose_count
    begin
      if $redis.get("shop_#{self.url}")
        return $redis.get("shop_#{self.url}")
      else
        self.dispose_count
      end
    rescue=>e
      self.dispose_count
    end
  end

  def get_dist_name
    area = Area.find_by_id(self.area_id)
    if area == nil
       return ""
    end
    if area.t == 'district'
       return area.name
    else
       area1 = Area.find_by_dp_id(area.parent_dp_id)
       if area1.t == 'district'
          return area1.name
       end
    end
    return ''
  end

  def shop_dist
    self.get_dist_name
  end

  def get_address
    dist_name = self.get_dist_name
    self.address = self.address.gsub(dist_name, '') 
    address =  "#{self.address}"
    m = address.force_encoding("ASCII-8BIT").match(/#{$street_pat}/)
    #if m and m.length >=5
    #    @dist_name = m[1].force_encoding("UTF-8")
    #    area = Area.find_by_name(@dist_name)
    #    if area and area.id != self.area_id
    #      self.area_id = area.id
    #      self.save! 
    #    end
    #end
    address = self.address
    if not m and self.address.index(dist_name) == nil
       p dist_name + self.address
       address =  dist_name + self.address
    end

    # just for lnglat parse 
    #p address
    #address = address.sub("南桥百联购物中心1楼", "")
    #address = address.sub("南桥百联购物中心2楼", "")
    #address = address.sub("莲花广场", "")
    #address = address.sub("南桥百联购物中心", "")
    #address = address.sub("太平洋百货1楼", "")
    address
  end
  
  def get_street
    if self.mall
      self.mall.name
    elsif self.shop_type == 11
      self.name
    elsif self.street
      self.street
    else
      ""
    end
  end

  def get_mall
    self.mall
  end

  def get_max_id
    Shop.maximum('id')
  end

  def address_tel
    if self.phone_number != ""
       self.address.to_s + "  #{self.phone_number}"
    else
       self.address.to_s
    end
  end

  def brand_name
    if self.brand.nil?
      ""
    else
      self.brand.get_display_name
    end
  end

  def get_display_name
    if self.brand
      shopname=self.brand.get_display_name
      if self.get_street
        shopname=shopname+"("+self.get_street+")"
      end
      shopname
    else
      self.shop_name
    end
  end

  def sync_discount
    brand_discount = nil
    if self.brand
        self.brand.discounts.sort_by{|discount| discount.updated_at}
        brand_discount=self.brand.discounts.last
    else
        return
    end 

    if not brand_discount
        return
    end
   
    discount = nil
    unless self.discounts.blank?
      self.discounts.sort_by{|discount| discount.updated_at}
      discount=self.discounts.last
    end
    if discount == nil or 1.days.since(discount.end_date) < brand_discount.start_date
      self.discounts.create(:title =>brand_discount.title, :reason =>brand_discount.reason, :discountable_type => "Shop", :brand_discount_id =>brand_discount.id, 
      :description => brand_discount.description, :start_date=>brand_discount.start_date, :end_date=>brand_discount.end_date)
    end
    if discount and discount.start_date == brand_discount.start_date and discount.end_date == brand_discount.end_date
      discount.update_attributes(:title =>brand_discount.title, :reason =>brand_discount.reason, :discountable_type => "Shop", :brand_discount_id =>brand_discount.id,
      :description => brand_discount.description, :start_date=>brand_discount.start_date, :end_date=>brand_discount.end_date)
    end
  end
  

  def sync_brand_sku(num=5)
    if self.level and self.level > 2 and self.brand_id and brand = Brand.find_by_id(self.brand_id) and brand.level.to_i >= 3
       idx = 0
       skus = brand.skus.sort_by{rand}
       for sku in skus
          if not sku.deleted and sku.category_id < 100 and 60.days.since(sku.created_at) > Time.now and sku.level.to_i >= 3
             next if sku.photos.length <= 0
             item  = Item.find_by_shop_id_and_sku_id(self.id, sku.id)
             unless item
                idx = idx + 1 
                if idx > num
                   break
                end 
                print "!!!new sku:", sku.level, sku.title, sku.id, " for ", self.url, "\n"
                i = Item.create(:shop_id=>self.id, :sku_id=>sku.id, :level=>sku.level, :title => self.id.to_s + "_" + sku.id.to_s)
                p i.id
             end
          end
       end
    end
  end 

  def sync_all_sku()
    if not self.brand or self.brand_id == 0
       items  = self.items
       items.each do |item|
          if item.sku
             p "delete item with", self.url, "/" ,item.url
             item.destroy        
          end
       end 
    end

    if self.brand
       brand_id  = self.brand.id
       if brand_id != 0 
         items  = self.items
         items.each do |item|
           if item.sku and item.sku.brand_id != brand_id
             p self.brand.name, "vs", item.sku.brand.name 
             p "delete bad barnd item with", self.url, "/" ,item.url
             item.destroy
           end
         end
       end
    end

    if self.level and self.level >=1 and self.brand_id and self.brand_id != 0 and brand = Brand.find_by_id(self.brand_id)
       idx = 0
       for sku in brand.skus
          item  = Item.find_by_shop_id_and_sku_id(self.id, sku.id)
          if item and sku.deleted
            #item.destroy
            item.deleted = true
            item.save
          elsif not sku.deleted 
            if not item
            #    self.items.create(:sku_id=>sku.id, :title=>sku.title, :category_id=>sku.category_id, :price => sku.price)
            else
              #item.title = sku.title  
              #item.category_id = sku.category_id
              #item.price = sku.price
              #item.origin_price = sku.origin_price
              #item.off_percent = sku.off_percent
              #item.from = sku.from
              #item.tags = sku.tags
              #item.color = sku.color
              item.level = sku.level  
              item.save
              print item.level, ":", item.shop.url, "/", item.url, " : ", item.from, sku.created_at, sku.level, "\n" 
            end
          end
       end
    end
  end 

  def sync_mall
    if self.mall_id
      m = Mall.find_by_id(self.mall_id)
      self.address = m.address if m.address and self.address == ""
      self.street = m.name
      self.alias = self.display_name + "(#{self.street}店)" 
      self.save 
    end
  end

  def incr_dispose
     key = "shop_#{self.url}"
     $redis.incr(key) 
  end


  def get_brand_intro
    if self.brand_intro and self.brand_intro != ""
      self.brand_intro
    else
      if self.brand
        self.brand.brand_intro
      end
    end
  end

  def get_price_level
    if self.price_level and self.price_level!=""
      self.price_level
    else
      if self.brand
        self.brand.price_level
      end
    end
  end

  def get_low_price
    if self.low_price
      self.low_price
    elsif self.brand and self.brand.low_price
      self.brand.low_price
    else
      #print "ppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppp"
      price_level=get_price_level
      #print price_level
      #print "^^^^"
      if price_level
        get_low_price_from_level(price_level)
      else
        -1
      end
    end
  end

  def get_low_price_s
    low_price=self.get_low_price
    low_price.to_s
  end

  def get_high_price
    if self.high_price
      self.high_price
    elsif self.brand and self.brand.high_price
      self.brand.high_price
    else
      #print "ppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppp"
      price_level=get_price_level
      #print price_level
      #print "^^^^"
      if price_level
        get_high_price_from_level(price_level)
      else
        -1
      end
    end
  end

  def get_high_price_s
    high_price=self.get_high_price
    high_price.to_s
  end


  def activate_from_dp
      last_comment_at  = nil
      s = self
      if s.comments and s.comments.length > 0
        last_comment_at = s.comments.last.created_at
        return if 30.days.since(last_comment_at) > Time.now
      end
      if s.dp_id and s.dp_id != "" and s.level.to_i >= 2
        dp_reviews = Dianping.new.get_reviews(s.dp_id)
        dp_reviews["reviews"].each do |r|
          p r
          name = r['user_nickname']
          content = r['text_excerpt']
          ct = r['created_time']
          ti = Time.parse(ct)
          if 180.days.since(ti) > Time.now and ( last_comment_at == nil or ti > last_comment_at )
            uname = "sjb#{Digest::MD5.hexdigest(name)}"
            email = "#{uname}@shangjieba.com"
            cu = User.find_by_email(email)
            cu = User.create(:name=>name, :email=>email, :password=>"fakeuser123", :real=>false ) unless cu
            print email, cu, "\n"
            c = s.comments.create(:commentable_type=>"Shop", :commentable_id=>s.id, :comment=>content, :user_id=>cu.id)
            print s.url, "\t", s.id, "\t", s.shop_name, "\n"

            if not s.level or s.level == 0
              s.level = 4
            end
            s.save!
          end
        end
      end
  end

  def get_distance
    if self.distance and self.distance.to_s != "-1"
      self.distance.to_s
    else
      ""
    end
  end

  def self.cache_recommend_shops_by_city_id(city_id)
    Rails.cache.fetch "recommend/shops/#{city_id}", :expires_in => 3.minutes do
      Shop.recommended(city_id).entries
    end
  end

private

  def get_low_price_from_level(price_level)
    res=price_level.match(/[a-z0-9\-]+/)
    if res
      low_price=-1
      res_array=res[0].split("-")
      if res_array.length>0
        low_price=res_array[0]
      end
      #print "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
      #print low_price
      low_price
    else
      -1
    end
  end

  def get_high_price_from_level(price_level)
    res=price_level.match(/[a-z0-9\-]+/)
    if res
      high_price=-1
      res_array=res[0].split("-")
      if res_array.length>1
        high_price=res_array[1]
      end
      #print "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
      #print low_price
      high_price
    else
      -1
    end
  end

  def get_pod_url
     pod_url = AppConfig[:pod_url].dup
     pod_url.chop! if AppConfig[:pod_url][-1,1] == '/'
     pod_url
  end

  def change_role
    if self.user
      #self.user.roles.each do |role|
      #  role.destroy
      #end
    end
  end

end
