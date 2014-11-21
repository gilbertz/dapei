# -*- encoding : utf-8 -*-
#encoding: utf-8
class Discount < ActiveRecord::Base
  include Sjb::Likeable
  include Sjb::Commentable

  validates :title, :presence => true, :length => { :maximum => 16 }
  attr_accessible :title, :reason, :description, :start_date, :end_date, :publish, :discountable_id, :discountable_type, :source, :from, :docid, :brand_discount_id, :discount_type
  attr_accessor :distance

  belongs_to :discountable, :polymorphic => true #, :counter_cache => true
  has_many :photos, :as => :target, :dependent=>:destroy
  has_one :recommend

  acts_as_commentable
  acts_as_api
  api_accessible :public, :cache => 180.minutes do |t|
    #t.add :id, :as=>:discount_id
    t.add lambda{|discount| discount.id.to_s}, :as => :discount_id
    t.add :get_show_title, :as => :title
    t.add lambda{|discount| discount.reason.to_s}, :as => :reason
    t.add :description
    t.add :start_date
    t.add :end_date
    t.add :remain_days
    t.add lambda{|discount| discount.likes_count.to_s}, :as => :likes_count
    t.add lambda{|discount| discount.get_dispose_count.to_s}, :as => :dispose_count
    t.add :shop_url, :as=>:shop_id
    t.add :shop_name
    t.add :shop_street, :as => :street
    t.add :shop_address
    t.add lambda{|d| d.brand.id.to_s if d.brand}, :as => :brand_id
    t.add :brand_avatar_url
    t.add :wide_avatar_url
    t.add :white_avatar_url
    t.add :black_avatar_url
    t.add :discount_img_urls
    t.add :img_wide_medium
    t.add :img_scaled_medium
    t.add :img_scaled_large
    t.add :like_id_s, :as=>:like_id
    t.add lambda {|discount| discount.distance.to_s}, :as => :distance
    t.add :share_url
    t.add :get_display_date, :as => :display_date    

    t.add lambda{|discount| discount.brand_campaign_img(:wide_half)}, :as => :wide_half_campaign_img
    t.add lambda{|discount| discount.brand_campaign_img(:wide_medium)}, :as => :wide_medium_campaign_img
    t.add :created_at
    t.add :updated_at
  end

  after_create :send_notifications

  api_accessible :error do |t|
    t.add :errors
  end

  scope :liked_by, lambda { |user|
    joins(:likes).where(:likes => {:user_id => user.id}).order("likes.created_at desc")
  }

  scope :recommended, lambda { |city_id|
    joins("INNER JOIN recommends ON recommends.recommended_id = discounts.id").joins("INNER JOIN shops ON shops.id = discounts.discountable_id").where("shops.city_id=#{city_id}").where('recommends.recommended_type' => "Discount").order("created_at desc").limit(20)
  }
 
  def self.selected_discounts(city_id)
    @discounts=[]
    @discounts=Discount.joins("INNER JOIN shops ON shops.id = discounts.discountable_id").where("discounts.end_date > ?", Date.today).where("discounts.deleted is NULL").where("shops.city_id=#{city_id} and discounts.discountable_type='Shop'").order("created_at desc").group("shops.brand_id").limit(8)
    #result=[]
    #selector={}
    #@discounts.each do |discount|
    #  #if discount.discountable_type=="Shop" and discount.is_current? and discount.discountable.level>3
    #  if discount.discountable_type=="Shop" and discount.discountable.level>1
    #    brand_name=discount.discountable.brand_name
    #    if brand_name and !selector[brand_name]
    #      selector[brand_name]=discount
    #      result<<discount
    #    end
    #  end
    #end
    #result
  end 
 
  def wide_avatar_url
    if self.brand
      self.brand.wide_avatar_url
    else
     AppConfig[:remote_image_domain] + "/uploads/static/weizhi.jpg"
    end
  end

  def white_avatar_url
    if self.brand
      self.brand.white_avatar_url
    else
      AppConfig[:remote_image_domain] + "/uploads/static/weizhi.jpg"
    end
  end

  def black_avatar_url
    if self.brand
      self.brand.black_avatar_url
    else
      AppConfig[:remote_image_domain] +"/uploads/static/weizhi.jpg"
    end
  end

  def brand
    if(self.discountable_type=="Shop")
      return self.discountable.brand
    end
    if(self.discountable_type=="Brand")
      return self.discountable
    end
  end


  def shop_url
    if(self.discountable_type=="Shop")
      return self.discountable.url
    end
    #if(self.discountable_type=="Mall")
      #return self.discountable.url
    #end
    "-1"
  end

  def share_url
    "http://www.shangjieba.com/weixin/discount?from=app&id=" + self.id.to_s
  end

  def remain_days
    if self.end_date and self.end_date > Date.today
      return (self.end_date-Date.today).to_i.to_s
    end
    return "-1"
  end

  def name
    self.title
  end

  def get_show_title
    #self.brand_name + " " + self.title
    self.title
  end

  def shop_name
    if(self.discountable_type=="Shop")
      return self.discountable.shop_name
    end
    if(self.discountable_type=="Mall")
      return self.discountable.name
    end
    ""
  end

  def shop_display_name
    if(self.discountable_type=="Shop")
      return self.discountable.display_name
    end
    if(self.discountable_type=="Mall")
      return self.discountable.name
    end
    ""
  end

  def shop_address
    if(self.discountable_type=="Shop")
      return self.discountable.address
    end
    if(self.discountable_type=="Mall")
      return self.discountable.address
    end
    ""
  end

  def is_current?
    if not self.deleted and self.end_date and self.end_date >= Date.today    
      return true
    end
    return false
  end

   def shop_city
     if(self.discountable_type=="Shop")
       return self.discountable.shop_city
     end
     if(self.discountable_type=="Mall")
     end
     ""
  end

  def shop_street
     if(self.discountable_type=="Shop")
       return self.discountable.get_street
     end
     ""
  end

  def brand_name
     if(self.discountable_type=="Shop" or self.discountable_type=="Brand")
       return self.discountable.brand_name
     end
     ""
  end

  def shop_dist
      if(self.discountable_type=="Shop")
        return self.discountable.shop_dist
      end
      ""
  end

  def shop_display_name
      if(self.discountable_type=="Shop")
         return self.discountable.shop_dist
      end
      ""
  end


  def brand_avatar_url
      if self.discountable_type=="Shop"
        return self.discountable.shop_avatar_url 
      end
      if self.discountable_type=="Brand"
        return self.discountable.get_avatar_url
      end
      if(self.discountable_type=="Mall")
        return self.discountable.profile_image
      end
  end


  
  def brand_campaign_img(size)
     if(self.discountable_type=="Shop")
       if self.discountable and self.discountable.brand
         return self.discountable.brand.wide_campaign_img(size)
       else
         return "http://www.shangjieba.com//uploads/static/weizhi.jpg" 
       end
     end
     ""
  end

  def brand_banner_url
     if(self.discountable_type=="Shop")
       if self.discountable and self.discountable.brand
         return self.discountable.brand.banner_url
       end
     end
     ""
  end


  def shop_avatar_url
     if(self.discountable_type=="Shop")
       return self.discountable.shop_avatar_url
     end
     if(self.discountable_type=="Mall")
       return self.discountable.profile_image
     end
  end

  def discount_img_urls
    img_urls=Array.new
    #default_url=get_pod_url+"/assets/img.jpg"
    default_url = brand_campaign_img(:wide_medium)
    if self.display_photos and self.display_photos.length>0
      self.display_photos.each do |photo|
        temp = {}
        temp[:img_url]=photo.url(nil)
        temp[:width]=photo.width
        temp[:height]=photo.height
        img_urls<<temp
      end
    else
      temp={:img_url=>default_url, :width=>"484", :height=>"180"} 
      img_urls<<temp
    end
    img_urls
  end

  def shop_img_url
     if(self.discountable_type=="Shop")
       unless self.discountable.shop_type == 11
         return self.discountable.img_url(:wide_medium)
       else
         "http://www.shangjieba.com//uploads/static/weizhi.jpg"
       end
     end
  end

  def jindu
    if(self.discountable_type=="Shop")
      return self.discountable.jindu
    end
    ""
  end

  def weidu
    if(self.discountable_type=="Shop")
      return self.discountable.weidu
    end
    ""
  end

  def url
    self.id
  end

  def get_dispose_count
    dc = 0
    if $redis.get("discount_#{self.id}")
      dc = $redis.get("discount_#{self.id}").to_i
    else
      self.dispose_count.blank? ? 0 : self.dispose_count
    end
    if(self.discountable_type=="Shop")
      dc = dc + self.discountable.get_dispose_count.to_i
    end
    dc
  end

  def avatar_url
    if(self.discountable_type=="Shop")
      return self.discountable.shop_avatar_url
    else
      ""
    end
  end
  
  def img_wide_medium
    if(self.discountable_type=="Shop")
      return self.discountable.img_url(:wide_medium)
    end
    if(self.discountable_type=="Mall")
       return self.discountable.profile_image
    end
    ""
  end

  def img_scaled_medium
    if self.display_photos and self.display_photos.length >= 1
      self.display_photos.first.url(:scaled_medium)
    else
      ""
    end
  end
  
  def img_scaled_large
    if self.display_photos and self.display_photos.length >= 1
      self.display_photos.first.url(:scaled_large)
    else
      ""
    end
  end

  def has_liked?
    if User.current_user and Like.has_liked?(User.current_user.id, self.id, "Discount")
      return true
    else
      return false
    end
  end

  def like_id
    like=Like.find_by_user_id_and_target_id_and_target_type(User.current_user.id, self.id, "Discount")
    like.id
  end

  def like_id_s
    like_id="0"
    if has_liked?
      like=Like.find_by_user_id_and_target_id_and_target_type(User.current_user.id, self.id, "Discount")
      like_id=like.id.to_s
    end
    like_id
  end

  def incr_dispose
     key = "discount_#{self.id}"
     $redis.incr(key)
  end


  def display_photos
      if self.brand_discount_id
        brand_discount = Discount.find_by_id(self.brand_discount_id)
        if brand_discount
          return brand_discount.photos
        end
      end   
      return  self.photos
  end

  def get_display_photo
    photo=nil
    if self.photos and self.photos.length>0
      self.display_photos.first
    else
      self.discountable.get_display_photo      
    end
  end

  def sub_discounts
    if self.discountable.instance_of?(Brand)
      return Discount.find_all_by_brand_discount_id(self.id)
    end
  end

  def get_display_date
    date=""
    if start_date
      date=date+start_date.month.to_s+"/"+start_date.day.to_s
    end
    if end_date
      date=date+ " - "+ end_date.month.to_s+"/"+end_date.day.to_s
    end
    date
  end

  
  def parent
    if self.brand_discount_id and  self.brand_discount_id > 0
       Discount.find_by_id(self.brand_discount_id)
    end
  end


  def self.discount_types
    return { 0 => "无",  1 => "优惠",  2 => "新品",  3 =>"资讯", 4 => "T台秀", 5 => "大片", 6 => "街拍",  7 => "故事"}
  end

  def self.get_types
     tags = []
     self.discount_types.each do |k, v|
       tags << [v, k]
     end
     tags
  end

  def format
    p "!!!!format discount"
    
    if self.description.index("转发微博") or self.description.index("回复@")
       self.deleted = true
       self.save
       return
    end
    photo = self.photos.first
    unless photo
      self.deleted = true
      return
    end
    print photo.url(nil)
    print photo.width, "X", photo.height, "\n"
    if photo.height / photo.width > 3
      self.deleted = true
      p "!!!bad photo"
      self.save
      return
    end

    tag = self.description.gsub(/(.*)#(.*?)#(.*)/, '\2')
    #self.description = self.description.gsub(/\##{tag}\#/, '')
    self.description = self.description.gsub(/\[(.*?)\]/, '')
    self.description = self.description.gsub(/@(.*?)[_:\]]/, '')

    if self.title == "新品资讯" and tag and tag != ""
      self.title = tag
    end
    p self.title, self.description
    self.save
     
  end

private

  def get_pod_url
     pod_url = AppConfig[:pod_url].dup
     pod_url.chop! if AppConfig[:pod_url][-1,1] == '/'
     pod_url
  end

  def send_notifications
    #if self.discountable_type != "Mall" and self.discountable_type != "Brand"
    #  @likers=self.discountable.get_likers
    #end
    
    if self.discountable_type == "Brand"
      likers = self.discountable.get_likers 
      likers.each do |user|
        user.set_ssq_status( self )
        user.set_ssq_notify_img(self.brand_avatar_url)        
        if user.bind_device
          # Resque.enqueue(Jobs::QueryNotify, user.id)
          QueryNotifyJob.perform_async(user.id)
        end
      end
    end
 
    #unless @likers.blank?
    #  @likers.uniq.each do |user|
    #    user.notify("A new discount", "Youre not supposed to see this", self)
    #  end
    #end
  end

  def deduplicate(discounts)
    result=[]
    selector={}
    discounts.each do |discount|
      if discount.discountable_type=="Shop" and discount.is_current?
        brand_name=discount.discountable.brand_name
        if brand_name and !selector[brand_name]  
          selector[brand_name]=discount
          result<<discount
        end
      end
    end
    result
  end

end
