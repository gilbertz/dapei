# -*- encoding : utf-8 -*-
class User < ActiveRecord::Base
  rolify
  acts_as_followable
  acts_as_follower
  acts_as_messageable
  acts_as_api
  mount_uploader :avatar, AvatarUploader

  after_create :send_notifications
  after_create :create_userinfo

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :token_authenticatable, :recoverable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable, omniauth_providers: [:weibo, :weixin, :qq_connect]
  #,:confirmable

  before_save :ensure_authentication_token, :check_user

  cattr_accessor :current_user
  attr_accessor :password_confirmation

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :email, :qq, :real, :password, :password_confirmation, :weixin, :address, :apply_type, :production_type, :phone, :brand_id, :site, :display_name, :remember_me, :is_girl, :url, :preurl, :mobile, :contact, :product_type, :level,:birthday, :age, :city, :district, :getting_started, :avatar, :avatar_cache, :desc, :profile_img_url, :dapeis_count
  has_many :comments, :dependent => :destroy
  has_many :likes, :dependent => :destroy
  has_many :items, :dependent => :destroy
  has_many :selfies, :class_name => "Item", :conditions => "type = 'Selfie'"
  
  #validates :mobile, :presence => true, :length =>{:is => 11}, :on => :update
  validates :email, :presence => true, :on => :update
  validates :email, :uniqueness => true, :on => :update
  validates_format_of :email, :with => /\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*/

  #validates :password, :length => { :minimum => 6,:message=>"密码太短了"}
  #validates :password, :presence=>true, :confirmation=>true, :on=>:update
  validates_length_of :name, :maximum => 160
  has_many :posts, :dependent => :destroy
  has_many :photos, :as => :target, :dependent => :destroy
  has_many :authentications

  has_many :messages, :foreign_key => "accept_id"

  has_many :followers
  has_many :followables
  has_many :user_behaviours

  has_one :userinfo
  has_many :daren_applies

  def my_cart
    if self.cart.blank?
      cart = self.build_cart
      cart.save
    else
      cart = self.cart
    end
    cart
  end

  def user_id
    url
  end

  def get_brand
    if self.brand_id
      Brand.find_by_id(self.brand_id)
    end
  end


  api_accessible :public, :cache => 60.minutes do |t|
    t.add :url, :as => :user_id
    t.add :mobile
    t.add lambda { |user| user.get_type }, :as => :apply_type
    t.add :display_name
    t.add :display_name, :as => :name
    t.add :get_sex, :as => :is_girl
    t.add lambda { |user| user.birthday.to_s }, :as => :birthday
    t.add lambda { |user| user.age.to_s }, :as => :age
    t.add lambda { |user| user.city.to_s }, :as => :city
    t.add lambda { |user| user.get_desc }, :as => :desc
    t.add :display_img_small, :as => :avatar_img_small
    t.add :display_img_medium, :as => :avatar_img_medium
    t.add :get_bg_img, :as => :bg_img
    t.add lambda { |user| user.following_count.to_s }, :as => :following_count
    t.add lambda { |user| user.followers_count.to_s }, :as => :followers_count
    t.add :is_following, :if => :can_following?
    t.add lambda { |user| user.dapei_count.to_s }, :as => :dapei_count
    t.add :v_dapei_count
    t.add :dapei_likes_count
    t.add lambda { |user| user.get_level.to_s }, :as => :level
    t.add :checked
    t.add :check_times
    t.add lambda { |user| user.mobile_state.to_s }, :as => :mobile_state
  end

  api_accessible :user_shop, :cache => 60.minutes do |t|
    t.add :url, :as => :user_id
    t.add :mobile
    t.add lambda { |user| user.get_type }, :as => :apply_type
    t.add :name
    t.add :name, :as => :display_name
    t.add :email
    t.add :weixin
    t.add :qq
    t.add :contact
    t.add :phone
    t.add :city
    t.add :address
    t.add lambda { |user| user.get_desc }, :as => :desc
    t.add :display_img_small, :as => :avatar_img_small
    t.add :display_img_medium, :as => :avatar_img_medium
    t.add :get_bg_img, :as => :bg_img
    t.add :is_following, :if => :can_following?
    t.add lambda { |user| user.followers_count.to_s }, :as => :followers_count
    t.add lambda { |user| user.dapei_count.to_s }, :as => :dapei_count
    t.add :v_dapei_count
    t.add :dapei_likes_count
    t.add lambda { |user| user.get_level.to_s }, :as => :level
  end


  api_accessible :get_like_users, :cache => 60.minutes do |t|
    t.add :url, :as => :user_id
    t.add :display_img_small, :as => :avatar_img_small
    t.add :display_img_medium, :as => :avatar_img_medium
    t.add :get_bg_img, :as => :bg_img
    t.add :is_following, :if => :can_following?
  end


  api_accessible :light, :cache => 60.minutes do |t|
    t.add :url, :as => :user_id
    t.add :display_name
    t.add :display_name, :as => :name
    t.add lambda { |user| user.get_desc }, :as => :desc
    t.add :is_following, :if => :can_following?
    t.add :display_img_small, :as => :avatar_img_small
    t.add :display_img_medium, :as => :avatar_img_medium

    t.add lambda { |user| user.dapei_count.to_s }, :as => :dapei_count
    t.add lambda { |user| user.followers_count.to_s }, :as => :followers_count
    t.add lambda { |user| user.get_level.to_s }, :as => :level
  end

  api_accessible :fast, :cache => 60.minutes do |t|
    t.add :url, :as => :user_id
    t.add :display_name, :as => :name
    t.add :is_following, :if => :can_following?
    t.add :display_img_small, :as => :avatar_img_small
    t.add :display_img_medium, :as => :avatar_img_medium

    t.add lambda { |user| user.get_level.to_s }, :as => :level
  end

  def get_type
    self.apply_type.to_i.to_s
  end

  def last_dapei
    dp = Dapei.where(:user_id => self.id).last
  end

  def last_dapei_time
    if self.last_dapei
      self.last_dapei.created_at
    end
  end

  def to_dict
    {
        :user_id => self.url,
        :name => self.display_name,
        :desc => self.get_desc,
        :is_following => self.is_following,
        :avatar_img_small => self.display_img_small,
        :level => self.get_level.to_s,
        :followers_count => self.followers_count.to_s,
        :dapei_count => self.dapei_count.to_s
    }
  end


  def get_intro_url
    "http://www.shangjieba.com/sjb/daren_applies/daren_info"
  end

  def dapei_pv_notify(dp_url, _pv=false)
    t = Time.now
    today = t.strftime("%Y%m%d")
    key = "dp_notify_#{dp_url}_#{today}"

    if t.hour >9 and t.hour < 23
      unless $redis.get(key)
        dp = Dapei.find_by_url(dp_url)
        pv = dp.get_dispose_count.to_i
        if _pv or pv > 1000
          PushNotification.push_dapei_pv(self.id, dp_url)
          $redis.set(key, 1)
        end
      else
        p 'Wait for tomorrow ...'
      end
    end
  end

  def checked
    today = Time.now.strftime("%Y%m%d")
    k3 = "#{self.id}_checked_#{today}"
    $redis.get(k3).to_s
  end

  def check_times
    yesterday = -1.days.since(Time.now).strftime("%Y%m%d")
    k4 = "#{self.id}_checked_#{yesterday}"
    if $redis.get(k4)
      k2 = "check_times_#{self.id}"
      $redis.get(k2).to_s
    else
      $redis.set(k2, 1)
      "1"
    end
  end

  def check_in_score
    k5 = "#{self.id}_check_in_score"
    $redis.get(k5).to_i
  end


  def check_in
    k1 = "check_at_#{self.id}"
    k2 = "check_times_#{self.id}"
    today = Time.now.strftime("%Y%m%d")
    yesterday = -1.days.since(Time.now).strftime("%Y%m%d")

    k3 = "#{self.id}_checked_#{today}"
    k4 = "#{self.id}_checked_#{yesterday}"
    k5 = "#{self.id}_check_in_score"

    check_in_score = $redis.get(k5).to_i

    last_check_in = $redis.get(k1)
    unless $redis.get(k3)
      if $redis.get(k4)
        $redis.incr(k2)
      else
        $redis.set(k2, 1)
      end

      #calculate check in score      
      check_times = $redis.get(k2).to_i
      check_in_score += check_times

      $redis.set(k5, check_in_score)
      $redis.set(k1, Time.now.to_i)
      $redis.set(k3, 1)
      return true
    else
      return false
    end
  end

  def level_names
    ['时尚新生', '时尚优等生', '时尚达人', '时尚领袖', '时尚女王']
  end

  def level_scores
    [0, 1000, 2000, 4000, 8000, 16000]
  end

  def get_fashion_level
    score = self.get_level_score

    level = 0
    idx = 0
    self.level_scores.each do |s|
      return level+idx if score < s
      idx += 1
    end
    if score > 8000
      return 5
    end
    return 1
  end

  def show_fashion_level
    "LV" + self.get_fashion_level.to_s
  end


  def get_level_name
    idx = self.get_fashion_level - 1
    self.level_names[idx]
  end


  def get_level_score
    self.dapei_score.to_i + self.check_in_score
  end

  def current_level_score
    idx = self.get_fashion_level - 1
    self.level_scores[idx]
  end

  def next_level_score
    idx = self.get_fashion_level
    self.level_scores[idx]
  end

  def get_experience
    {
        :level => self.get_fashion_level.to_s,
        :name => self.get_level_name,
        :score => self.get_level_score.to_s,
        :check_in_score => self.check_times.to_s,
        :current_level_score => self.current_level_score.to_s,
        :next_level_score => self.next_level_score.to_s
    }
  end

  def get_active_honour
    honours = []
    Honour.active.each do |h|
      if Honour.find_by_user_id_and_honour_id(self.id, h.id)
        honour = {:active => "1", :name => h.name, :img => h.img, :small_img => h.small_image, :url => h.url}
        honours << honour
      end
    end
    honours
  end


  def get_honour_images
    images = []
    Honour.active.each do |h|
      if Honour.find_by_user_id_and_honour_id(self.id, h.id)
        images << h.small_image
      end
    end
    images
  end


  def get_honour
    honours = []
    Honour.active.each do |h|
      honour = {:active => "1", :name => h.name, :img => h.img, :small_img => h.small_image, :url => h.url}
      obj = Honour.find_by_user_id_and_honour_id(self.id, h.id)
      if not obj or not obj.active
        honour[:active] = "0"
        honour[:img] = h.img_1
      end
      honours << honour
    end

    honours
  end


  def set_honour(hid, is_active=true)
    h = Honour.find_by_user_id_and_honour_id(self.id, hid)
    dd= {}
    dd[1] = "搭配之星勋章"
    dd[3] = "蜜蜂勋章"
    dd[5] = "热心勋章"

    is_push = false
    if h
      h.active = is_active
      if h.active == false and is_active == true
        is_push = true
      end
      h.save
    else
      is_push = true
      Honour.create(:user_id => self.id, :honour_id => hid)
    end
    if is_push
      PushNotification.push_msg(self.id, '恭喜你获得' + dd[hid] + ", 继续加油哦！")
    end
  end


  def check_honour
    #check 蜜蜂xin章
    if self.check_times.to_i >= 5
      self.set_honour(3)
    else
      self.set_honour(3, false)
    end

    #check 搭配之星
    star_dapeis = Dapei.where(:user_id => self.id).where("level >=5 ")
    if star_dapeis.length >= 1
      self.set_honour(1)
    else
      self.set_honour(1, false)
    end

    #check 热心勋章
    if self.dapei_responses_count.to_i >= 5
      self.set_honour(5)
    end
  end


  api_accessible :error do |t|
    t.add :errors
  end

  scope :recommended, lambda { |city_id|
    where("1=1").order("dapei_score desc").order("created_at desc").limit(45)
    #where("comments_count is not null").order("comments_count desc").limit(45)
  }

  scope :system_users, lambda { where(:level => 100) }

  def self.cache_recommended_by_city_id(city_id)
    Rails.cache.fetch "users/recommend/city_id/#{city_id}", :expires_in => 3.minutes do
      User.recommended(city_id).entries
    end
  end

  #Returning the email address of the model if an email should be sent for this object (Message or Notification).
  #If no mail has to be sent, return nil.
  #Currently, just return nil. Need to be improved later.
  def mailboxer_email(object)
    #If user has disabled the emails, return nil. 
    #return nil if !notify_by_email
    #If user has enabled the emails and has email
    #return "#{name} <#{email}>" if email.present?
    return nil
  end


  def get_sex
    if self.is_girl == "女性" or self.is_girl == "女"
      self.is_girl = "1"
    elsif self.is_girl == "男性" or self.is_girl == "男"
      self.is_girl = "0"
    end
    self.is_girl
  end


  def push_msg
    PushNotification.push_notify(self.id)
  end


  def get_desc
    if self.desc.blank?
      "爱搭配, 爱生活"
    else
      self.desc.to_s
    end
  end


  def set_ssq_status(obj=nil)
    key = "user_#{self.id}_ssq_status"
    $redis.set(key, Time.now.to_i)
    if obj.instance_of?(Item)
      self.set_ssq_notify_img(obj.user_img_small)
    end
    if obj.instance_of?(Discount)
      self.set_ssq_notify_img(obj.brand_avatar_url)
    end
  end


  def get_ssq_status
    key = "user_#{self.id}_ssq_status"
    if $redis.get(key)
      $redis.get(key)
    else
      0
    end
  end

  def set_ssq_notify_img(img)
    key = "user_#{self.id}_ssq_img"
    $redis.set(key, img)
  end


  def get_ssq_notify_img
    key = "user_#{self.id}_ssq_img"
    if $redis.get(key)
      $redis.get(key)
    else
      self.display_img_small
    end
  end

  def set_notify_status
    key = "user_#{self.id}_notify_status"
    $redis.set(key, Time.now.to_i)
  end


  def get_notify_status
    key = "user_#{self.id}_notify_status"
    if $redis.get(key)
      $redis.get(key)
    else
      0
    end
  end


  def get_ssq_read
    key = "user_#{self.id}_ssq_read"
    if $redis.get(key)
      read = $redis.get(key)
    else
      read = 0
    end
    #$redis.set( key, Time.now.to_i )
    return read
  end


  def get_notify_read
    key = "user_#{self.id}_notify_read"
    if $redis.get(key)
      read = $redis.get(key)
    else
      read = 0
    end
    return read
  end


  def get_dapei_classroom_status
    key = "user_#{self.id}_dapei_classroom_status"
    post = Post.is_show.first
    post.created_at.to_i
  end


  def get_dapei_classroom_read
    key = "user_#{self.id}_dapei_classroom_read"
    if $redis.get(key)
      read = $redis.get(key)
    else
      read = 0
    end
    return read
  end


  def set_dapei_classroom_read
    key = "user_#{self.id}_dapei_classroom_read"
    $redis.set(key, Time.now.to_i)
  end


  def set_ssq_read
    key = "user_#{self.id}_ssq_read"
    $redis.set(key, Time.now.to_i)
  end


  def set_notify_read
    key = "user_#{self.id}_notify_read"
    $redis.set(key, Time.now.to_i)
  end

  def query_notify
    return unless self.bind_device
    unless self.query_notify_waiting
      key = "user_#{self.id}_waiting_status"
      $redis.set(key, Time.now.to_i)
      # Resque.enqueue(Jobs::QueryNotify, self.id)
      QueryNotifyJob.perform_async(self.id)
    end
  end

  def query_notify_waiting
    key = "user_#{self.id}_waiting_status"
    return read = $redis.get(key)
  end

  def query_notify_done
    key = "user_#{self.id}_waiting_status"
    $redis.del key
  end

  def bind_device
    return false unless UserDevice.find_by_user_id(self.id)
    return true
  end


  def has_new_msg
    new_ssq = self.get_ssq_read.to_i < self.get_ssq_status.to_i
    return true if new_ssq
    new_notify = self.get_notify_read.to_i < self.get_notify_status.to_i
    return new_notify
  end

  def get_bg_img
    if self.bg_photo_id
      photo = Photo.find_by_id(self.bg_photo_id)
      if photo
        photo.url(nil)
      else
        User.default_bg_img
      end
    else
      User.default_bg_img
    end
  end


  def self.default_head_img
    AppConfig[:qiniu_image_domain]  + "/img/tou.gif"
  end

  def self.default_bg_img
    AppConfig[:qiniu_image_domain]  +  "/img/tou_bg.png"
  end


  def posts_count_s
    count=posts_count.blank? ? 0 : self.posts_count
    count.to_s
  end

  def dapeis
    #unless self.is_fake
    Dapei.dapeis_by(self)
    #else
    #  Dapei.fake_by(self)
    #end
  end

  def dapei_count
    #if self.is_fake
    #  dc = Dapei.dapeis_by(self).length
    #  dc.to_s
    #else
    self.dapeis_count.to_s
    #end
    count=self.dapeis_count+self.selfies.length
    count.to_s
  end

  def v_dapeis
    Dapei.v_dapeis_by(self)
  end

  def v_dapei_count
    dc = self.v_dapeis.length
    dc.to_s
  end


  def star_dapeis
    Dapei.star_dapeis_by(self)
  end

  def star_dapei_count
    self.star_dapeis.length
  end


  def dapei_likes_count
    dc = Dapei.dapeis_by(self)
    likes_count = 0
    unless self.is_fake
      dc.each do |dp|
        likes_count += dp.likes_count
      end
    end
    likes_count
  end

  def like_spec
    spec = ""
    self.likes.order('created_at desc').limit(10).each do |l|
      spec += "#{l.target_type[0]}"
    end
    spec
  end


  def dapei_comments_count
    dc = Dapei.dapeis_by(self)
    comments_count = 0
    unless self.is_fake
      dc.each do |dp|
        comments_count += dp.comments_count
      end
    end
    comments_count
  end

  before_save :downcase_email

  def downcase_email
    self.email.downcase!
  end

  before_validation :auto_slug

  def auto_slug
    if self.url.blank?
      if !self.name.blank?
        #self.url=self.name.to_url
        self.url=self.name
      elsif !self.email.blank?
        self.url = self.email.split("@")[0]
        #self.url = self.url.to_url
      end
      if self.url.blank?
        self.url = self.id.to_s
      end
      self.url = self.url.gsub("`", "").gsub("~", "")
      self.url=self.url.to_url
    end

    old_user=User.find_by_url(self.url)
    if !old_user.blank? and old_user.id!=self.id
      self.url=self.url + User.maximum('id').to_s
    end
  end

  def to_param
    self.url
  end

  def display_name
    if self.name and self.name!=""
      self.get_name
    else
      self.email.split("@")[0]
    end
  end

  def display_img_small
    self.display_img_medium
  end

  def display_img_medium
    img_url = User.default_head_img
    if self.photos and self.photos.length>0
      self.photos.sort_by { |photo| photo.created_at }
      img_url=self.photos.last.url(:thumb_small)
    elsif self.profile_img_url
      img_url=self.profile_img_url
    end
   
    if self.is_shop and self.get_brand
      img_url = self.get_brand.avatar_url
    end


    if img_url
      unless img_url.include? "http:"
        img_url = AppConfig[:remote_image_domain] + img_url
      end
    end
    img_url
  end

  def build_post(class_name, opts={})
    opts[:author] = self
    model_class = class_name.to_s.camelize.constantize
    model_class.initialize(opts)
  end

  def like!(target_type, target_id)
    target = target_type.constantize
    if (target_type == "Post" or target_type == "Matter")
      target_id = target_id.to_i
    else
      target_id = target.find_by_url(target_id).id
    end
    if not Like.has_liked? self.id, target_id, target_type
      likeable = target.find(target_id)
      like = likeable.likes.create({:target_type => target_type, :target_id => target_id, :user_id => self.id})
    end
  end

  def dislike!(target_type, target_id)
    target = target_type.constantize
    if (target_type == "Post" or target_type == "Matter")
      target_id = target_id.to_i
    else
      target_id = target.find_by_url(target_id).id
    end
    if Like.has_liked? self.id, target_id, target_type
      like = Like.find_by_user_id_and_target_id_and_target_type(self.id, target_id, target_type)
      like.destroy if like
    end
  end


  def can_remove?(comment)
    if self.id==comment.user_id or self.can_be_admin
      return true
    else
      return false
    end
  end

  def can_following?
    if current_user and current_user!=self
      return true
    else
      return false
    end
  end

  def is_following
    if can_following? and current_user.following?(self)
      return "1"
    else
      return "0"
    end
  end

  def can_be_admin
    self.id == 1
    #self.has_role? :admin and not self.has_role? :shop_owner
  end

  def following_count
    #self.following_by_type_count('User')
    if self.userinfo.blank?
      Userinfo.create!(:user_id => self.id)
    end
    self.userinfo.following_count
  end

  def followers_count
    if self.userinfo.blank?
      Userinfo.create!(:user_id => self.id)
    end
    #self.followers_by_type_count('User')
    if self.userinfo.blank?
      Userinfo.create!(:user_id => self.id)
    end

    self.userinfo.followers_count
  end

  def unread_notifications_count
    mailbox.notifications.not_trashed.unread.count
  end

  def update_with_password(params={})
    if !params
      params={}
      params.merge :user => {}
    end
    if !params[:current_password].blank? or !params[:password].blank? or !params[:password_confirmation].blank?
      super
    else
      params.delete(:current_password)
      self.update_without_password(params)
    end
  end

  def names
    ["yz", "chris", "lace", "gg", "cli", "yfl", "cm", "xiaoyu", "dayu", "yaya", "hong", "dan", "jun", "jovity", "whitney", "grace", "bear", "haj", "sarah"]
  end

  def get_name
    return '匿名天使' unless self.name

    pat = /^u\d+$/
    if pat.match(self.name)
      return self.name.gsub('u', '匿名')
    end

    pat = /sh\d+/
    if pat.match(self.name)
      idx= (self.name[2, 6].to_i)%(names.length)
      names[idx] + self.name[4, 2]
    elsif self.name != "sjb"
      self.name
    else
      idx = (self.id)%(names.length)
      names[idx] + self.url[-3, 3]
    end
  end

  def get_level
    self.level.to_i
  end

  def get_daren_status
    if self.level.to_i == 1
      "申请中"
    elsif self.level.to_i >=2
      "#{self.level}级商家"
    else
      "普通"
    end
  end

  def get_upload_limit
    (1 + self.get_level) * 200
  end

  def get_uploaded_count
    Matter.created_by(self).count
  end

  def can_upload
    #if self.get_uploaded_count <= self.get_upload_limit
    #  "1"
    #else
    #  "0"
    #end
    "1"
  end

  def self.get_admin
    User.find_by_id(362637)
  end

  def rand_followed
    to_like_num = rand(2) + 1
    for n in (1..to_like_num)
      uid = rand(29500)
      user = User.find_by_id(uid)
      if user
        user.follow(self)
      end
    end
  end

  def send_notifications
    self.notify("welcome", "Youre not supposed to see this", self)
    self.set_notify_status
    self.query_notify
    self.rand_followed
  end

  def mark_as_ad
    self.level = -1
    self.save
  end

  def cancel_as_ad
    self.level = 0
    self.save
  end

  def is_fake
    return false if Dapei.find_by_user_id(self.id)
    return (self.id > 10 and self.id < 29500)
  end

  def is_real
    return (self.id < 10 or self.id > 29500)
  end

  def is_robot
    self.level == 100 or self.id < 30000
  end

  def get_debug_name
    return self.name + '(假)' if self.is_robot
    self.name
  end

  def login_json
    {:error => "0", :apply_type => self.apply_type.to_s, :mobile_state => self.mobile_state.to_s, :level => self.get_level.to_s, :age => self.age.to_s, :birthday => self.birthday.to_s, :city => self.city.to_s, :bg_img => self.get_bg_img, :is_girl => self.is_girl.to_s, :avatar_img_medium => self.display_img_medium, :display_name => self.display_name.to_s, :user_id => self.url.to_s, :token => self.authentication_token}
  end

  def fix_name
    if self.shop
      ns = []
      ns = self.name.split('-') if self.name
      if ns.length >= 3
        self.name = ns[0] + ns[1]
        self.save
      end
      #p self.name
      return self.name
    end
  end

  def self.create_by_token(token)
    email = "sbb" + Digest::MD5.hexdigest(token) + "@shangjieba.com"
    user = User.find_by_email(email)
    uid = User.maximum('id') % 100000
    user = User.create(:name => "u#{uid}", :email => email, :password => "weixin") unless user
    if user
      user.authentication_token = token
      user.save
    end
    user
  end

  def is_comment
    self.authentication_token.index('shangjieba-')
  end


  def social_score
    social_score = self.following_count + self.followers_count + self.dapei_likes_count + self.dapei_comments_count * 2
    social_score / 10
  end

  def update_dapei_score
    dp_score = self.dapei_count.to_i + self.v_dapei_count.to_i * 10 + self.star_dapei_count.to_i*100
    self.dapei_score = dp_score + self.social_score
    self.save
  end

  def update_dapei_counter
    self.class.where(:id => self.id).
        update_all(:dapeis_count => Dapei.dapeis_by(self).count)
  end

  def notify_go_home

  end


  def didi
    user = self
    user.set_notify_status
    if user
      if user.get_notify_read.to_i < user.get_notify_status.to_i
        PushNotification.push_notify(id)
      end
      if user.get_ssq_read.to_i < user.get_ssq_status.to_i
        PushNotification.push_ssq(id)
      end

      if user.get_dapei_classroom_read.to_i < user.get_dapei_classroom_status.to_i
        PushNotification.push_dapei_classroom(id)
      end
    end
    user.query_notify_done
  end


  # 检查下user.name
  def check_user
    if self.name.blank?
      self.name = ''
    end
  end

  # 得到用户标记过的品牌tags
  def brand_tags
    brand_tags = $redis.zrevrange("user_brand_tags_#{self.id}", 0, -1)
    if brand_tags.blank? # 如果用户没的任何品牌标签,返回前十个品牌标签
      brand_tags = Brand.api_get_brands
    end
    brand_tags[0..10] #只返前十条
  end

  def set_brand_tag(name)
    $redis.zincrby("user_brand_tags_#{self.id}", 1, name)
  end

  # 得到用户标记过的品牌tags
  def get_ctags
    user_ctags = $redis.zrevrange("user_ctags_#{self.id}", 0, -1)
    user_ctags.first(10)#只返前十条
  end
                                
  def set_ctag(name)
    $redis.zincrby("user_ctags_#{self.id}", 1, name)
  end

  def mobile_verified(mobile)
    self.mobile = mobile
    self.mobile_state = 1
    self.save
  end

  def get_token
    self.authentication_token.to_s
  end

  def is_shop
    (self.apply_type.to_i > 0 )
  end

  def self.create_by_brand(brand_id)
    brand = Brand.find_by_id brand_id
    if brand
      u = User.find_by_brand_id(brand.id)
      unless u
        username = brand.url + Devise.friendly_token[0,20]
        email = username+"@dapeimishu.com"
        password = Devise.friendly_token[0,20]
        u = User.new
        u.name = brand.display_name
        u.email = email
        u.password = password
        u.brand_id = brand.id
        u.remember_me = 1
        u.save 
      end
      u
    end
  end

  def self.by_brand(brand_id)
    User.where(:brand_id => brand_id).last
  end

  private
  def get_pod_url
    pod_url = AppConfig[:pod_url].dup
    pod_url.chop! if AppConfig[:pod_url][-1, 1] == '/'
    pod_url
  end

  def create_userinfo
    Userinfo.create(:user_id => self.id) unless Userinfo.find_by_user_id(self.id)
  end

end
